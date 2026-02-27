"""
Split a PDF into 7 equal parts.
Just run: python split_pdf_7parts.py
"""

import math
import os
from pypdf import PdfReader, PdfWriter


# ── Change this path if needed ──────────────────────────────────────
INPUT_PATH = r"C:\Users\ASUS\Downloads\book.pdf"
# ────────────────────────────────────────────────────────────────────


def split_pdf_into_7(input_path):
    reader = PdfReader(input_path)
    total_pages = len(reader.pages)

    if total_pages < 7:
        print(
            f"Warning: The PDF has only {total_pages} pages. Some parts may be empty."
        )

    pages_per_part = total_pages / 7
    base_name = os.path.splitext(os.path.basename(input_path))[0]
    output_dir = os.path.dirname(os.path.abspath(input_path))

    print(f"PDF has {total_pages} pages. Splitting into 7 parts...")

    for part in range(7):
        start_page = math.floor(part * pages_per_part)
        end_page = math.floor((part + 1) * pages_per_part)

        if part == 6:
            end_page = total_pages

        writer = PdfWriter()
        for page_num in range(start_page, end_page):
            writer.add_page(reader.pages[page_num])

        output_path = os.path.join(output_dir, f"{base_name}_part{part + 1}.pdf")
        with open(output_path, "wb") as output_file:
            writer.write(output_file)

        print(f"  Part {part + 1}: pages {start_page + 1}–{end_page} → {output_path}")

    print("\nDone! 7 parts created successfully.")


split_pdf_into_7(INPUT_PATH)
