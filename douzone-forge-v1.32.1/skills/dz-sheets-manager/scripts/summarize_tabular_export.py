#!/usr/bin/env python3
"""
Summarize a CSV/TSV export from a spreadsheet tab.

Usage:
    summarize_tabular_export.py <path>
    summarize_tabular_export.py <path> --delimiter tab
"""

from __future__ import annotations

import argparse
import csv
from collections import Counter
from pathlib import Path


STATUS_KEYS = [
    "상태",
    "진행상황",
    "테스트 결과",
    "개발 검수 결과",
    "설계 검수 결과",
]


def choose_delimiter(raw: str) -> str:
    if raw == "tab":
        return "\t"
    if raw == "comma":
        return ","
    return raw


def find_status_columns(headers: list[str]) -> list[str]:
    found = []
    for header in headers:
        normalized = header.strip()
        if normalized in STATUS_KEYS:
            found.append(normalized)
    return found


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("path")
    parser.add_argument(
        "--delimiter",
        default="comma",
        help="comma, tab, or a literal single-character delimiter",
    )
    args = parser.parse_args()

    path = Path(args.path)
    delimiter = choose_delimiter(args.delimiter)

    with path.open("r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f, delimiter=delimiter)
        headers = reader.fieldnames or []
        rows = list(reader)

    print(f"# Tabular Export Summary: {path.name}")
    print()
    print(f"- row_count: {len(rows)}")
    print(f"- column_count: {len(headers)}")
    print(f"- columns: {', '.join(headers)}")

    status_columns = find_status_columns(headers)
    if not status_columns:
        print("- status_columns: none")
        return 0

    print(f"- status_columns: {', '.join(status_columns)}")
    print()

    for column in status_columns:
        counter = Counter()
        for row in rows:
            value = (row.get(column) or "").strip()
            if value:
                counter[value] += 1

        print(f"## {column}")
        if not counter:
            print("- no non-empty values")
            print()
            continue

        for key, value in counter.most_common():
            print(f"- {key}: {value}")
        print()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
