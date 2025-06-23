#!/usr/bin/env python3
"""
Performance Comparison Script for GPU Simulator Configurations
Compares metric values across different configurations for the same workloads.
"""

import os
import re
import glob
import math
import argparse
import sys
from collections import defaultdict


def truncate_workload_name(workload_name, max_length=50):
    """Truncate workload name to specified length, adding '...' if truncated."""
    if len(workload_name) <= max_length:
        return workload_name
    else:
        return workload_name[:max_length-3] + "..."


def extract_metric(log_file, metric_name, sequence_id=None):
    """Extract metric value from a log file at a specific sequence ID."""
    try:
        with open(log_file, 'r') as f:
            content = f.read()
            # Find all metric lines with flexible pattern matching
            # Supports formats like: metric_name: value, metric_name = value, metric_name value
            metric_lines = re.findall(rf'{re.escape(metric_name)}\s*[:=]\s*([\d.]+)', content)
            if metric_lines:
                if sequence_id is not None and sequence_id < len(metric_lines):
                    return float(metric_lines[sequence_id])
                else:
                    # If no specific sequence_id or out of range, return the last one
                    return float(metric_lines[-1])
    except (FileNotFoundError, ValueError, IOError):
        pass
    return None


def get_common_sequence_id(workload, configs, metric_name):
    """Find the common sequence ID that exists across all configurations for a workload."""
    sequence_counts = []
    
    for config in configs:
        log_file = f"./{config}/logs_queue/{workload}.log"
        try:
            with open(log_file, 'r') as f:
                content = f.read()
                metric_lines = re.findall(rf'{re.escape(metric_name)}\s*[:=]\s*([\d.]+)', content)
                sequence_counts.append(len(metric_lines))
        except (FileNotFoundError, IOError):
            sequence_counts.append(0)
    
    # Find the minimum number of sequences across all configurations
    min_sequences = min(sequence_counts) if sequence_counts else 0
    
    if min_sequences > 0:
        # Use the last common sequence ID (min_sequences - 1, since indexing starts at 0)
        return min_sequences - 1
    else:
        return None


def get_all_workloads():
    """Get all unique workload names across all configurations."""
    workloads = set()
    for log_file in glob.glob("./*/logs_queue/*.log"):
        workload = os.path.splitext(os.path.basename(log_file))[0]
        workloads.add(workload)
    return sorted(workloads)


def get_configurations(specified_configs=None):
    """Get configuration directories.
    
    Args:
        specified_configs: Optional list of specific configuration names to include.
                          If None, returns all available configurations.
    """
    if specified_configs:
        # Return only the specified configurations that exist
        configs = []
        for config in specified_configs:
            if os.path.isdir(f"./{config}"):
                configs.append(config)
            else:
                print(f"Warning: Configuration directory '{config}' not found")
        return sorted(configs)
    else:
        # Return all configuration directories
        configs = []
        for dir_path in glob.glob("./*"):
            if os.path.isdir(dir_path):
                config_name = os.path.basename(dir_path)
                configs.append(config_name)
        return sorted(configs)


def check_config_has_logs_queue(config):
    """Check if a configuration has a logs_queue directory with log files."""
    logs_queue_dir = f"./{config}/logs_queue"
    return os.path.isdir(logs_queue_dir) and len(glob.glob(f"{logs_queue_dir}/*.log")) > 0


def get_display_name(config):
    """Get display name for configuration by removing 'run_' prefix."""
    if config.startswith('run_'):
        return config[4:]  # Remove 'run_' prefix
    return config


def calculate_geometric_mean(values):
    """Calculate geometric mean of a list of values."""
    if not values:
        return None
    # Filter out None values and ensure all values are positive
    valid_values = [v for v in values if v is not None and v > 0]
    if not valid_values:
        return None
    return math.exp(sum(math.log(v) for v in valid_values) / len(valid_values))


def compare_performance(metric_name, configs=None):
    """Compare metric performance across configurations."""
    workloads = get_all_workloads()
    configs = get_configurations(configs)
    
    if not workloads:
        print("No log files found in */logs_queue/ directories")
        return
    
    if not configs:
        print("No configuration directories found")
        return
    
    # Filter configurations that have log files
    valid_configs = [config for config in configs if check_config_has_logs_queue(config)]
    missing_configs = [config for config in configs if not check_config_has_logs_queue(config)]
    
    if missing_configs:
        print(f"Warning: The following configurations don't have log files and will be excluded:")
        for config in missing_configs:
            print(f"  - {config}")
        print()
    
    if not valid_configs:
        print("No configurations with valid log files found")
        return
    
    print(f"=== Performance Comparison ({metric_name}) Across Configurations ===")
    print()
    
    # Print table header
    header = f"{'Workload':<53}"
    for config in valid_configs:
        display_name = get_display_name(config)
        header += f"{display_name:<15}"
    for config in valid_configs:
        if config != 'run' and config != 'cache':
            display_name = get_display_name(config)
            header += f"{display_name:<15}"
    print(header)
    
    # Print separator
    separator = "-" * 53
    for config in valid_configs:
        separator += "-" * 15
    for config in valid_configs:
        if config != 'run' and config != 'cache':
            separator += "-" * 15
    print(separator)
    
    # Collect data for analysis
    performance_data = defaultdict(dict)
    improvement_data = defaultdict(dict)
    
    # For each workload, compare metric across configurations
    for workload in workloads:
        # Find the common sequence ID for this workload across all configurations
        common_sequence_id = get_common_sequence_id(workload, valid_configs, metric_name)
        
        if common_sequence_id is not None:
            print(f"Debug: {workload} using sequence ID {common_sequence_id}")
        
        # Truncate workload name for display
        display_workload = truncate_workload_name(workload, 50)
        row = f"{display_workload:<53}"
        workload_data = {}
        
        # First pass: collect all metric values at the common sequence ID
        for config in valid_configs:
            log_file = f"./{config}/logs_queue/{workload}.log"
            metric_value = extract_metric(log_file, metric_name, common_sequence_id)
            
            if metric_value is not None:
                row += f"{metric_value:<15.4f}"
                workload_data[config] = metric_value
            else:
                row += f"{'-':<15}"
                workload_data[config] = None
        
        # Second pass: calculate percentage improvements over 'run' baseline
        baseline = workload_data.get('cache')
        for config in valid_configs:
            if config != 'cache':
                current_value = workload_data.get(config)
                if baseline is not None and baseline != 0 and current_value is not None:
                    improvement = 100.0 * (current_value - baseline) / baseline
                    row += f"{improvement:>+8.2f}%      "
                    improvement_data[workload][config] = improvement
                else:
                    row += f"{'-':<15}"
                    improvement_data[workload][config] = None
        
        print(row)
        performance_data[workload] = workload_data
    
    # Print geometric mean row
    print(separator)
    geo_mean_row = f"{'Geometric Mean':<53}"
    
    # Calculate geometric mean for each configuration
    for config in valid_configs:
        values = [data.get(config) for data in performance_data.values()]
        geo_mean = calculate_geometric_mean(values)
        if geo_mean is not None:
            geo_mean_row += f"{geo_mean:<15.4f}"
        else:
            geo_mean_row += f"{'-':<15}"
    
    # Calculate geometric mean for improvements
    for config in valid_configs:
        if config != 'run' and config != 'cache':
            improvements = [data.get(config) for data in improvement_data.values()]
            valid_improvements = [imp for imp in improvements if imp is not None]
            if valid_improvements:
                # Convert percentage improvements to ratios for geometric mean
                ratios = [(100 + imp) / 100 for imp in valid_improvements]
                geo_mean_ratio = calculate_geometric_mean(ratios)
                if geo_mean_ratio is not None:
                    geo_mean_improvement = (geo_mean_ratio - 1) * 100
                    geo_mean_row += f"{geo_mean_improvement:>+8.2f}%      "
                else:
                    geo_mean_row += f"{'-':<15}"
            else:
                geo_mean_row += f"{'-':<15}"
    
    print(geo_mean_row)
    
    print()
    print("=== Performance Analysis ===")
    
    # Find best configuration for each workload with improvement percentage
    for workload, data in performance_data.items():
        valid_data = {k: v for k, v in data.items() if v is not None}
        if valid_data:
            best_config = max(valid_data, key=valid_data.get)
            baseline = valid_data.get('run')
            
            if baseline is not None and baseline != 0:
                improvement = 100.0 * (valid_data[best_config] - baseline) / baseline
                best_display_name = get_display_name(best_config)
                # Truncate workload name for analysis section too
                display_workload = truncate_workload_name(workload, 20)
                print(f"{display_workload:<20}: Best configuration = {best_display_name:<20} (improvement = {improvement:>+8.2f}%)")
            else:
                best_display_name = get_display_name(best_config)
                display_workload = truncate_workload_name(workload, 20)
                print(f"{display_workload:<20}: Best configuration = {best_display_name:<20} (improvement = -)")
    
    print()
    print("=== Summary ===")
    print(f"Legend: Higher {metric_name} values indicate better performance")
    print("Percentage columns show improvement over 'run' baseline configuration")
    print(f"{metric_name} values are compared at the same sequence ID across configurations")
    print("Geometric mean provides overall performance comparison across all workloads")
    print("-: Log file not found or metric not present")
    print("Note: Workload names longer than 50 characters are truncated with '...'")


def main():
    """Main function to handle command-line arguments and run the comparison."""
    parser = argparse.ArgumentParser(
        description="Compare performance metrics across different GPU simulator configurations",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 compare_performance.py tot_ipc
  python3 compare_performance.py gpu_simulation_time
  python3 compare_performance.py gpgpu_simulation_rate
  python3 compare_performance.py "gpgpu_simulation_rate"
  python3 compare_performance.py tot_ipc --configs cache,double_l1cache,quadruple_l1cache
  python3 compare_performance.py tot_ipc --configs run,run_double_cache,run_four_cache
        """
    )
    
    parser.add_argument(
        'metric',
        help='Metric name to compare (e.g., tot_ipc, gpu_simulation_time, gpgpu_simulation_rate)'
    )
    
    parser.add_argument(
        '--configs',
        help='Comma-separated list of specific configurations to compare (e.g., cache,double_l1cache,quadruple_l1cache). If not specified, all available configurations will be used.'
    )
    
    args = parser.parse_args()
    
    # Parse configurations if specified
    configs = None
    if args.configs:
        configs = [config.strip() for config in args.configs.split(',')]
        print(f"Using specified configurations: {', '.join(configs)}")
        print()
    
    # Run the comparison
    compare_performance(args.metric, configs)


if __name__ == "__main__":
    main() 
