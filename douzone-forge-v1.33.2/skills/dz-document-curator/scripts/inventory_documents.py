#!/usr/bin/env python3
"""
Build a quick inventory of incoming documents and group likely version families.

Usage:
    inventory_documents.py <directory>
"""

from __future__ import annotations

import argparse
import re
import subprocess
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path


VERSION_RE = re.compile(r"_v(\d+(?:\.\d+)*)$", re.IGNORECASE)
BRACKET_PREFIX_RE = re.compile(r"^\[[^\]]+\]\s*")
AUTHOR_SUFFIX_RE = re.compile(r"\(([^()]*)\)$")


@dataclass
class FileInfo:
    path: Path
    ext: str
    raw_stem: str
    clean_title: str
    group_key: str
    version: str | None
    version_key: tuple[int, ...]
    pdf_mod_date: str | None


def parse_version(stem: str) -> tuple[str | None, tuple[int, ...], str]:
    match = VERSION_RE.search(stem)
    if not match:
        return None, tuple(), stem
    version = match.group(1)
    version_key = tuple(int(part) for part in version.split("."))
    clean = VERSION_RE.sub("", stem)
    return version, version_key, clean


def clean_title(stem: str) -> str:
    stem = BRACKET_PREFIX_RE.sub("", stem).strip()
    stem = AUTHOR_SUFFIX_RE.sub("", stem).strip()
    stem = re.sub(r"\s+", " ", stem)
    return stem


def group_key(title: str) -> str:
    key = title
    key = key.replace("화면설계서", "화면설계")
    key = key.replace(" ", "")
    key = key.replace("_", "")
    return key


def read_pdf_mod_date(path: Path) -> str | None:
    if path.suffix.lower() != ".pdf":
        return None
    try:
        result = subprocess.run(
            ["pdfinfo", str(path)],
            check=True,
            capture_output=True,
            text=True,
        )
    except Exception:
        return None

    for line in result.stdout.splitlines():
        if line.startswith("ModDate:"):
            return line.split(":", 1)[1].strip()
    return None


def build_inventory(root: Path) -> list[FileInfo]:
    items: list[FileInfo] = []
    for path in sorted(p for p in root.iterdir() if p.is_file()):
        version, version_key, stem_without_version = parse_version(path.stem)
        title = clean_title(stem_without_version)
        items.append(
            FileInfo(
                path=path,
                ext=path.suffix.lower(),
                raw_stem=path.stem,
                clean_title=title,
                group_key=group_key(title),
                version=version,
                version_key=version_key,
                pdf_mod_date=read_pdf_mod_date(path),
            )
        )
    return items


def print_report(root: Path, items: list[FileInfo]) -> None:
    print(f"# Document Inventory: {root}")
    print()
    print(f"- files: {len(items)}")
    print(f"- pdf: {sum(1 for item in items if item.ext == '.pdf')}")
    print(f"- xlsx: {sum(1 for item in items if item.ext == '.xlsx')}")
    print()

    groups: dict[str, list[FileInfo]] = defaultdict(list)
    for item in items:
        groups[item.group_key].append(item)

    for key in sorted(groups):
        family = sorted(groups[key], key=lambda item: item.version_key)
        keep = family[-1]
        print(f"## {keep.clean_title}")
        print(f"- files: {len(family)}")
        print(f"- keep_candidate: {keep.path.name}")
        if keep.version:
            print(f"- keep_version: v{keep.version}")
        if keep.pdf_mod_date:
            print(f"- keep_pdf_mod_date: {keep.pdf_mod_date}")
        print("- members:")
        for item in family:
            status = "keep"
            if item.path != keep.path:
                status = "older-candidate"
            line = f"  - [{status}] {item.path.name}"
            if item.version:
                line += f" (v{item.version})"
            if item.pdf_mod_date:
                line += f" | pdf_mod={item.pdf_mod_date}"
            print(line)
        print()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("directory")
    args = parser.parse_args()

    root = Path(args.directory)
    items = build_inventory(root)
    print_report(root, items)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
