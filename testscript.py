# test_generator.py
import json
import sqlite3
from datetime import datetime, date
from pathlib import Path
import sys
import os

# Set the root path to your project
ROOT_PATH = r"C:\Users\erikl\TeamsApps\Teams401k\HohimerPro_IGNORE"
BACKEND_PATH = os.path.join(ROOT_PATH, "backend")

# Add the backend directory to Python path
sys.path.insert(0, BACKEND_PATH)

# Now import from the backend
from services.payment_service import (
    calculate_expected_fee, 
    calculate_periods,
    check_split_payment_status,
    calculate_payment_variance
)
from services.contract_service import calculate_expected_fee as contract_expected_fee
from services.client_service import get_current_period
from utils.constants import MONTH_NAMES

class TestCaseGenerator:
    def __init__(self):
        self.test_cases = {
            "fee_calculations": [],
            "period_calculations": [],
            "split_payment_detection": [],
            "variance_calculations": [],
            "available_periods": [],
            "compliance_status": [],
            "date_calculations": []
        }
    
    def generate_fee_calculation_tests(self):
        """Test expected fee calculations for different contract types"""
        test_scenarios = [
            # Flat fee contract
            {
                "name": "flat_fee_monthly",
                "payment_data": {
                    "fee_type": "flat",
                    "flat_rate": 500.00,
                    "percent_rate": None,
                    "total_assets": 100000
                },
                "description": "Flat fee contract should ignore assets"
            },
            # Percentage fee with assets
            {
                "name": "percentage_fee_with_assets",
                "payment_data": {
                    "fee_type": "percentage",
                    "flat_rate": None,
                    "percent_rate": 0.0025,  # 0.25%
                    "total_assets": 100000
                },
                "description": "Percentage fee with assets provided"
            },
            # Percentage fee without assets
            {
                "name": "percentage_fee_no_assets",
                "payment_data": {
                    "fee_type": "percentage",
                    "flat_rate": None,
                    "percent_rate": 0.0025,
                    "total_assets": None
                },
                "description": "Percentage fee without assets should return None"
            }
        ]
        
        for scenario in test_scenarios:
            result = calculate_expected_fee(scenario["payment_data"])
            self.test_cases["fee_calculations"].append({
                "input": scenario["payment_data"],
                "expected_output": result,
                "test_name": scenario["name"],
                "description": scenario["description"]
            })
    
    def generate_period_calculation_tests(self):
        """Test period calculations for split payments"""
        test_scenarios = [
            # Monthly split payment
            {
                "name": "monthly_split_3_months",
                "payment": {
                    "actual_fee": 1500,
                    "applied_start_month": 1,
                    "applied_start_month_year": 2024,
                    "applied_end_month": 3,
                    "applied_end_month_year": 2024,
                    "applied_start_quarter": None,
                    "applied_end_quarter": None
                },
                "description": "Split payment across 3 months"
            },
            # Quarterly split payment
            {
                "name": "quarterly_split_2_quarters",
                "payment": {
                    "actual_fee": 1000,
                    "applied_start_quarter": 1,
                    "applied_start_quarter_year": 2024,
                    "applied_end_quarter": 2,
                    "applied_end_quarter_year": 2024,
                    "applied_start_month": None,
                    "applied_end_month": None
                },
                "description": "Split payment across 2 quarters"
            },
            # Cross-year monthly split
            {
                "name": "monthly_split_cross_year",
                "payment": {
                    "actual_fee": 2000,
                    "applied_start_month": 11,
                    "applied_start_month_year": 2023,
                    "applied_end_month": 2,
                    "applied_end_month_year": 2024,
                    "applied_start_quarter": None,
                    "applied_end_quarter": None
                },
                "description": "Split payment across year boundary"
            }
        ]
        
        for scenario in test_scenarios:
            result = calculate_periods(scenario["payment"])
            self.test_cases["period_calculations"].append({
                "input": scenario["payment"],
                "expected_output": result,
                "test_name": scenario["name"],
                "description": scenario["description"]
            })
    
    def generate_split_payment_detection_tests(self):
        """Test split payment detection logic"""
        test_scenarios = [
            # Single month payment
            {
                "name": "single_month_payment",
                "payment": {
                    "applied_start_month": 1,
                    "applied_start_month_year": 2024,
                    "applied_end_month": 1,
                    "applied_end_month_year": 2024,
                    "applied_start_quarter": None,
                    "applied_end_quarter": None
                }
            },
            # Split monthly payment
            {
                "name": "split_monthly_payment",
                "payment": {
                    "applied_start_month": 1,
                    "applied_start_month_year": 2024,
                    "applied_end_month": 3,
                    "applied_end_month_year": 2024,
                    "applied_start_quarter": None,
                    "applied_end_quarter": None
                }
            },
            # Single quarter payment
            {
                "name": "single_quarter_payment",
                "payment": {
                    "applied_start_quarter": 1,
                    "applied_start_quarter_year": 2024,
                    "applied_end_quarter": 1,
                    "applied_end_quarter_year": 2024,
                    "applied_start_month": None,
                    "applied_end_month": None
                }
            }
        ]
        
        for scenario in test_scenarios:
            is_split, periods = check_split_payment_status(scenario["payment"])
            self.test_cases["split_payment_detection"].append({
                "input": scenario["payment"],
                "expected_output": {
                    "is_split": is_split,
                    "periods": periods
                },
                "test_name": scenario["name"]
            })
    
    def generate_variance_calculation_tests(self):
        """Test variance calculations"""
        test_scenarios = [
            {"name": "exact_match", "actual": 500, "expected": 500},
            {"name": "acceptable_variance", "actual": 510, "expected": 500},  # 2% over
            {"name": "warning_variance", "actual": 550, "expected": 500},     # 10% over
            {"name": "alert_variance", "actual": 600, "expected": 500},       # 20% over
            {"name": "null_actual", "actual": None, "expected": 500},
            {"name": "null_expected", "actual": 500, "expected": None},
        ]
        
        for scenario in test_scenarios:
            payment_data = {
                "actual_fee": scenario["actual"],
                "expected_fee": scenario["expected"],
                "fee_type": "flat",
                "flat_rate": scenario["expected"]
            }
            result = calculate_payment_variance(payment_data)
            self.test_cases["variance_calculations"].append({
                "input": {
                    "actual_fee": scenario["actual"],
                    "expected_fee": scenario["expected"]
                },
                "expected_output": result,
                "test_name": scenario["name"]
            })
    
    def save_test_cases(self):
        """Save all test cases to a JSON file in the root directory"""
        output_file = os.path.join(ROOT_PATH, "test_cases.json")
        
        with open(output_file, 'w') as f:
            json.dump(self.test_cases, f, indent=2, default=str)
        print(f"Test cases saved to {output_file}")
        
        # Also create a summary
        print("\nTest Case Summary:")
        for category, cases in self.test_cases.items():
            print(f"  {category}: {len(cases)} test cases")

def main():
    print(f"Working with project at: {ROOT_PATH}")
    print(f"Backend path: {BACKEND_PATH}")
    
    # Verify the paths exist
    if not os.path.exists(ROOT_PATH):
        print(f"ERROR: Root path does not exist: {ROOT_PATH}")
        return
    
    if not os.path.exists(BACKEND_PATH):
        print(f"ERROR: Backend path does not exist: {BACKEND_PATH}")
        return
    
    generator = TestCaseGenerator()
    
    print("\nGenerating test cases from Python backend...")
    
    try:
        generator.generate_fee_calculation_tests()
        generator.generate_period_calculation_tests()
        generator.generate_split_payment_detection_tests()
        generator.generate_variance_calculation_tests()
        generator.save_test_cases()
        
        print("\nTest cases have been generated successfully!")
        print("Use test_cases.json as your conversion verification guide.")
        
    except ImportError as e:
        print(f"\nERROR: Could not import backend modules.")
        print(f"Details: {e}")
        print("\nMake sure you're running this from the correct location")
        print("and that all backend files are present.")
    except Exception as e:
        print(f"\nERROR: {e}")
        print("An unexpected error occurred while generating test cases.")

if __name__ == "__main__":
    main()