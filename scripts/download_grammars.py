import os
import subprocess
import toml
import shutil
import tarfile
import zipfile
from pathlib import Path
from urllib.parse import urlparse

def is_archive(filename):
    return any(filename.endswith(ext) for ext in ['.zip', '.tar.gz', '.tgz'])

def unpack_archive(filepath, extract_to):
    if filepath.suffix == ".zip":
        with zipfile.ZipFile(filepath, 'r') as zip_ref:
            zip_ref.extractall(extract_to)
    elif filepath.suffix == ".tgz" or filepath.suffixes[-2:] == ['.tar', '.gz']:
        with tarfile.open(filepath, 'r:gz') as tar_ref:
            tar_ref.extractall(extract_to)
    else:
        print(f"⚠️ Unknown archive format: {filepath}")
        return False
    return True

def download_projects(toml_path, output_dir, delete_archives=True):
    with open(toml_path, "r", encoding="utf-8") as f:
        config = toml.load(f)

    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    for project, info in config.items():
        print(f"\n==> Downloading {project}")
        project_dir = output_dir / project
        project_dir.mkdir(exist_ok=True)

        vcs = info.get("vcs")
        if not vcs:
            print(f"⚠️  No 'vcs' key for {project}, skipping.")
            continue

        # Parse and download
        if vcs.startswith("wget "):
            url = vcs.split(" ", 1)[1]
        elif vcs.startswith("git clone "):
            url = vcs.split(" ", 2)[2]
            print(f"Cloning repo: {url}")
            try:
                subprocess.run(["git", "clone", url, "."], cwd=project_dir, check=True)
            except subprocess.CalledProcessError as e:
                print(f"❌ Git clone failed for {project}: {e}")
            continue
        elif vcs.startswith("http"):
            url = vcs
        else:
            print(f"⚠️  Unknown vcs format: {vcs}")
            continue

        # Download the file
        parsed_url = urlparse(url)
        filename = Path(parsed_url.path).name
        dest_file = project_dir / filename

        print(f"Downloading {url} to {dest_file}")
        try:
            subprocess.run(["wget", "-O", str(dest_file), url], check=True)
        except subprocess.CalledProcessError as e:
            print(f"❌ Download failed for {project}: {e}")
            continue

        # Unpack if archive
        if is_archive(dest_file.name):
            print(f"Unpacking {dest_file}...")
            success = unpack_archive(dest_file, project_dir)
            if success and delete_archives:
                dest_file.unlink()
                print(f"Deleted archive: {dest_file}")
        else:
            print("Not an archive file—skipping unpacking.")

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Download and unpack projects from a TOML manifest.")
    parser.add_argument("toml_file", help="Path to TOML file")
    parser.add_argument("output_dir", help="Directory to download projects into")
    parser.add_argument("--keep-archives", action="store_true", help="Keep archive files after unpacking")

    args = parser.parse_args()
    download_projects(args.toml_file, args.output_dir, delete_archives=not args.keep_archives)
