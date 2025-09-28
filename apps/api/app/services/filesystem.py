import os
import shutil
import subprocess
from pathlib import Path
from typing import Optional


def ensure_dir(path: str) -> None:
    Path(path).mkdir(parents=True, exist_ok=True)


def init_git_repo(repo_path: str) -> None:
    subprocess.run(["git", "init"], cwd=repo_path, check=True)
    subprocess.run(["git", "add", "-A"], cwd=repo_path, check=True)
    subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=repo_path, check=True)


def scaffold_nextjs_minimal(repo_path: str) -> None:
    """Create Next.js project by copying from template instead of running create-next-app
    
    This avoids network dependencies and potential timeouts or permission issues
    when running npx create-next-app in server environments.
    """
    import shutil
    
    # Get parent directory and project name
    parent_dir = Path(repo_path).parent
    project_name = Path(repo_path).name
    
    try:
        from app.core.terminal_ui import ui
        from app.core.config import settings
        
        # Path to the template directory
        # First check if template is in the project root
        template_path = os.path.join(settings.project_root, "templates", "nextjs-template")
        
        # If template doesn't exist in project root, try relative to current file
        if not os.path.exists(template_path):
            current_file_dir = os.path.dirname(os.path.abspath(__file__))
            project_root = os.path.join(current_file_dir, "..", "..", "..", "..", "..")
            project_root = os.path.abspath(project_root)
            template_path = os.path.join(project_root, "templates", "nextjs-template")
        
        if not os.path.exists(template_path):
            ui.error(f"Next.js template not found at {template_path}", "Filesystem")
            raise Exception(f"Next.js template directory not found. Please ensure it exists at {template_path}")
        
        ui.info(f"Using Next.js template from: {template_path}", "Filesystem")
        
        # Ensure the target directory exists and is empty
        if os.path.exists(repo_path):
            shutil.rmtree(repo_path)
        os.makedirs(repo_path, exist_ok=True)
        
        # Copy template files to the project directory
        for item in os.listdir(template_path):
            source = os.path.join(template_path, item)
            destination = os.path.join(repo_path, item)
            
            if os.path.isdir(source):
                shutil.copytree(source, destination)
            else:
                shutil.copy2(source, destination)
        
        # Update package.json with project name
        package_json_path = os.path.join(repo_path, "package.json")
        if os.path.exists(package_json_path):
            import json
            with open(package_json_path, 'r') as f:
                package_data = json.load(f)
            
            package_data["name"] = project_name
            
            with open(package_json_path, 'w') as f:
                json.dump(package_data, f, indent=2)
        
        ui.success(f"Created Next.js app from template at: {repo_path}", "Filesystem")
        
    except Exception as e:
        from app.core.terminal_ui import ui
        ui.error(f"Error creating Next.js app from template: {str(e)}", "Filesystem")
        raise Exception(f"Failed to create Next.js project: {str(e)}")


def write_env_file(project_dir: str, content: str) -> None:
    (Path(project_dir) / ".env").write_text(content)
