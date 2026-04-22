import os
import re
import sys

def migrate():
    print("Migrating Wilder to Non-Docker setup...")
    
    # 1. Update .env.example or create .env
    env_file = ".env"
    example_file = ".env.example"
    
    base_env = ""
    if os.path.exists(example_file):
        with open(example_file, "r") as f:
            base_env = f.read()
    
    # Replacement patterns for Docker -> Local
    replacements = [
        (r"DATABASE_URL=.*", "DATABASE_URL=\"file:./wilder.db\""),
        (r"STORAGE_TYPE=.*", "STORAGE_TYPE=\"local\""),
        (r"S3_.*=.*", "# S3 variables disabled for non-docker setup"),
        (r"USER_ID=.*", "USER_ID=\"1000\""), # Typical default
        (r"GROUP_ID=.*", "GROUP_ID=\"1000\""),
    ]
    
    new_env = base_env
    for pattern, replacement in replacements:
        if re.search(pattern, new_env):
            new_env = re.sub(pattern, replacement, new_env)
        else:
            new_env += f"\n{replacement}"
            
    with open(env_file, "w") as f:
        f.write(new_env)
    print(f"Created/Updated {env_file} with SQLite and Local Storage config.")

    # 2. Patch drizzle.config.ts if it exists to support sqlite
    # (Assuming the original uses postgres)
    drizzle_config = "drizzle.config.ts"
    if os.path.exists(drizzle_config):
        with open(drizzle_config, "r") as f:
            content = f.read()
        
        if "pg" in content.lower():
            content = content.replace("'pg'", "'better-sqlite3'")
            content = content.replace('"pg"', '"better-sqlite3"')
            print(f"Patched {drizzle_config} for SQLite.")
            with open(drizzle_config, "w") as f:
                f.write(content)

    print("Migration script completed successfully.")

if __name__ == "__main__":
    migrate()
