#!/bin/bash
# organize_for_github.sh
# Script to organize files for GitHub upload

echo "🚀 Organizing AI Judge files for GitHub..."

# Create project directory
PROJECT_DIR="ai-judge-hipaa-evaluation"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create folder structure
echo "📁 Creating folder structure..."
mkdir -p prompts
mkdir -p implementation
mkdir -p docs
mkdir -p examples

# Copy root files
echo "📄 Copying root files..."
cp ../README.md .
cp ../INDEX.md .
cp ../QUICK_REFERENCE.md .
cp ../requirements.txt .

# Copy prompt files
echo "📝 Copying prompt files..."
cp ../ai_judge_prompt.md prompts/
cp ../ai_judge_prompt_condensed.md prompts/

# Copy implementation files
echo "💻 Copying implementation files..."
cp ../ai_judge_evaluation.ipynb implementation/
cp ../ai_judge_implementation.py implementation/

# Copy documentation files
echo "📚 Copying documentation files..."
cp ../evaluation_criteria_assessment.md docs/
cp ../prompt_version_comparison.md docs/
cp ../ai_judge_usage_guide.md docs/
cp ../NOTEBOOK_GUIDE.md docs/
cp ../PACKAGE_SUMMARY.md docs/
cp ../FINAL_SUMMARY.md docs/

# Create .gitignore
echo "🚫 Creating .gitignore..."
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
*.egg-info/
dist/
build/

# Jupyter
.ipynb_checkpoints/
*.ipynb_checkpoints

# Data files (exclude from git)
*.jsonl
*.csv
!examples/*.csv

# API keys and secrets
.env
config.ini
*.key

# OS
.DS_Store
Thumbs.db
.vscode/
.idea/

# Test outputs
test_output/
results/
EOF

# Create LICENSE (MIT)
echo "📜 Creating LICENSE file..."
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2024 [Your Name/Institution]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Create example README files for empty folders
echo "Creating folder README files..."
cat > examples/README.md << 'EOF'
# Examples

This folder contains example test cases and results.

## Files

- `sample_responses.json` - Example AI responses to evaluate
- `sample_evaluations.jsonl` - Example evaluation results

## Usage

```python
import json

# Load example responses
with open('examples/sample_responses.json', 'r') as f:
    responses = json.load(f)
```
EOF

# Summary
echo ""
echo "✅ Files organized successfully!"
echo ""
echo "📊 Directory structure:"
tree -L 2 || ls -R

echo ""
echo "📍 Project location: $PWD"
echo ""
echo "🎯 Next steps:"
echo "1. cd ai-judge-hipaa-evaluation"
echo "2. git init"
echo "3. git add ."
echo "4. git commit -m 'Initial commit'"
echo "5. git remote add origin https://github.com/yourusername/ai-judge-hipaa-evaluation.git"
echo "6. git push -u origin main"
echo ""
echo "See GITHUB_UPLOAD_GUIDE.md for detailed instructions!"
