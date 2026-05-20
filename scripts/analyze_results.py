"""
analyze_results.py

Takes a CSV with LLM verification results and enriches it with an "iterations"
column (inserted after "llm_answer") that counts how many failed Forge test files
exist for each (contract_id, property_id) pair.

Failed test files are looked up in:
    forge_results/<contract>/<version>/test/*_<property_id>_*failed*

Usage:
    python analyze_results.py <input_csv>

Output: <input_stem>_analyzed.csv written next to the input file.
"""

import csv
import os
import sys
from pathlib import Path


def find_forge_results_root(script_dir: Path) -> Path:
    """Return the forge_results directory, searching upward from the script."""
    candidate = script_dir.parent / "forge_results"
    if candidate.is_dir():
        return candidate
    # Fallback: search relative to cwd
    candidate = Path.cwd() / "forge_results"
    if candidate.is_dir():
        return candidate
    raise FileNotFoundError(
        f"Could not locate 'forge_results' directory near {script_dir}"
    )


def count_failed_iterations(forge_results_root: Path, contract_id: str, property_id: str) -> int:
    """
    Count failed test files for a given (contract_id, property_id) pair.

    Searches all contract subdirectories under forge_results_root for a version
    folder matching v<contract_id>/test/, then counts files whose name contains
    both '_<property_id>_' and 'failed'.
    """
    count = 0

    # Iterate over contract-level subdirs (e.g. forge_results/bank/)
    for contract_dir in sorted(forge_results_root.iterdir()):
        if not contract_dir.is_dir():
            continue

        version_test_dir = contract_dir / f"v{contract_id}" / "test"
        if not version_test_dir.is_dir():
            continue

        for entry in version_test_dir.iterdir():
            if not entry.is_file():
                continue
            name = entry.name
            # Must contain 'failed' in the filename
            if "failed" not in name:
                continue
            # Property must appear as a full segment surrounded by underscores
            # (avoids partial matches like deposit-revert vs deposit-not-revert)
            if f"_{property_id}_" in name:
                count += 1

    return count


def analyze_results(input_csv: str) -> None:
    input_path = Path(input_csv).resolve()
    output_path = input_path.parent / (input_path.stem + "_analyzed" + input_path.suffix)

    script_dir = Path(__file__).parent.resolve()
    forge_results_root = find_forge_results_root(script_dir)

    with open(input_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        if reader.fieldnames is None:
            raise ValueError("Input CSV has no header row.")
        original_fieldnames = list(reader.fieldnames)
        rows = list(reader)

    # Build new fieldnames: insert "iterations" right after "llm_answer"
    if "llm_answer" not in original_fieldnames:
        raise ValueError("Expected column 'llm_answer' not found in CSV header.")
    if "iterations" in original_fieldnames:
        new_fieldnames = original_fieldnames  # already present, just update values
    else:
        insert_pos = original_fieldnames.index("llm_answer") + 1
        new_fieldnames = (
            original_fieldnames[:insert_pos]
            + ["iterations"]
            + original_fieldnames[insert_pos:]
        )

    # Annotate each row
    for row in rows:
        contract_id = row.get("contract_id", "").strip()
        property_id = row.get("property_id", "").strip()
        row["iterations"] = count_failed_iterations(forge_results_root, contract_id, property_id)

    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=new_fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Analyzed {len(rows)} rows.")
    print(f"Output written to: {output_path}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python analyze_results.py <input_csv>")
        sys.exit(1)
    analyze_results(sys.argv[1])
