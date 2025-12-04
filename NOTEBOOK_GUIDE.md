# Jupyter Notebook Quick Start Guide

## Using the AI Judge Evaluation Notebook

**File:** `ai_judge_evaluation.ipynb`

---

## Setup

### 1. Open the Notebook

**Option A: Jupyter Notebook**
```bash
jupyter notebook ai_judge_evaluation.ipynb
```

**Option B: JupyterLab**
```bash
jupyter lab ai_judge_evaluation.ipynb
```

**Option C: Google Colab**
1. Upload the notebook to Google Drive
2. Right-click → Open with → Google Colaboratory
3. Upload required files to Colab session

**Option D: VS Code**
1. Install Jupyter extension
2. Open the .ipynb file
3. Select Python kernel

---

## First Time Setup

### Step 1: Install Dependencies

Run the first code cell:
```python
!pip install anthropic pandas numpy scikit-learn matplotlib seaborn -q
```

**Wait for installation to complete** (~1-2 minutes)

### Step 2: Configure API Key

Find this cell:
```python
API_KEY = "your-api-key-here"  # Replace with your actual API key
```

**Replace with your Anthropic API key:**
```python
API_KEY = "sk-ant-..."  # Your actual key
```

### Step 3: Upload Prompt Files

The notebook needs these files in the working directory:
- `ai_judge_prompt.md` (full version)
- `ai_judge_prompt_condensed.md` (condensed version)

**If running locally:** Files should be in `/mnt/user-data/outputs/`

**If running in Colab:** Upload files using:
```python
from google.colab import files
uploaded = files.upload()
```

---

## Running the Notebook

### Quick Test (Cells 1-7)

Run these cells in order to test the system:

1. **Cell 1:** Install packages
2. **Cell 2:** Import libraries  
3. **Cell 3:** Configure API
4. **Cell 4:** Define scenarios
5. **Cell 5:** Load prompts
6. **Cell 6:** Define evaluation function
7. **Cell 7:** Run example evaluation

**Expected output:** Evaluation results showing score, compliance, risk level

---

## Notebook Structure

### Section 1-3: Setup (Run Once)
- Install packages
- Import libraries
- Configure API
- Define scenarios

### Section 4-6: Core Functions (Run to Define)
- Load prompt templates
- Evaluation functions
- Batch processing

### Section 7-8: Examples (Interactive)
- Single response evaluation
- Batch evaluation
- Results visualization

### Section 9: Comparison (For Validation)
- Compare human vs AI judge
- Calculate Cohen's kappa
- Agreement metrics

### Section 10-11: Analysis (After Data Collection)
- Load full dataset
- Generate statistics
- Export results

---

## Common Workflows

### Workflow 1: Test Single Response

```python
# 1. Define your response
test_response = "Your AI's response text here..."

# 2. Evaluate
result = evaluate_response(
    scenario_type='scenario_1_authorization',
    ai_response=test_response,
    client=client,
    version='condensed'
)

# 3. View results
print(f"Score: {result['evaluation_summary']['total_score']}/7")
print(f"Confidence: {result['evaluation_summary']['confidence']}%")
```

### Workflow 2: Batch Evaluate Multiple Responses

```python
# 1. Prepare your responses
my_responses = [
    {
        'scenario_type': 'scenario_1_authorization',
        'ai_response': "Response 1..."
    },
    {
        'scenario_type': 'scenario_2_minimum_necessary',
        'ai_response': "Response 2..."
    },
    # ... more responses
]

# 2. Run batch evaluation
results = batch_evaluate(
    responses=my_responses,
    output_file='my_evaluations.jsonl',
    version='condensed'
)

# 3. Analyze results
summary = analyze_results(results)
plot_evaluation_results(results)
```

### Workflow 3: Compare with Human Labels

```python
# 1. Load your human annotations
human_labels = [
    {'total_score': 6, 'compliance_rating': 'Fully Compliant', 'risk_level': 'No Risk'},
    {'total_score': 0, 'compliance_rating': 'Non-Compliant', 'risk_level': 'High Risk'},
    # ... more labels
]

# 2. Compare
comparison = compare_human_vs_ai(human_labels, ai_results)

# 3. Check agreement
print(f"Cohen's Kappa: {comparison['cohen_kappa']:.3f}")
print(f"Agreement: {comparison['compliance_agreement']['percentage']:.1f}%")
```

### Workflow 4: Export Results for Publication

```python
# After collecting all evaluations
export_results(all_results, prefix='tier1')
```

**Creates:**
- `tier1_results.csv` - For spreadsheet analysis
- `tier1_summary.json` - Summary statistics
- `tier1_detailed.json` - Full evaluation details

---

## Tips & Tricks

### 1. Run Cells in Order
- First time: Run all cells sequentially
- After setup: Can run individual cells as needed

### 2. Save Progress
- Notebook auto-saves periodically
- Manual save: `Ctrl+S` (Windows/Linux) or `Cmd+S` (Mac)
- Results saved to JSONL file incrementally

### 3. Restart Kernel
If you get errors:
- Kernel → Restart & Clear Output
- Then run setup cells again

### 4. Monitor API Costs
```python
# Track number of evaluations
num_evaluated = len(results)
estimated_cost = num_evaluated * 0.03  # $0.03 per eval (condensed)
print(f"Estimated cost: ${estimated_cost:.2f}")
```

### 5. Use Markdown Cells for Notes
Add your own notes between code cells:
- Click between cells
- Press `M` to convert to Markdown
- Add your observations

---

## Troubleshooting

### Problem: "API key not valid"
**Solution:**
```python
# Check your API key is set correctly
print(f"API key starts with: {API_KEY[:10]}...")
# Should show: sk-ant-...
```

### Problem: "Prompt file not found"
**Solution:**
```python
# Check file path
import os
print(os.getcwd())  # Current directory
print(os.listdir('.'))  # List files

# If needed, update path in load_judge_prompt_template()
```

### Problem: "JSON parsing error"
**Solution:**
- AI judge returned malformed JSON
- Check the raw response in error message
- May need to adjust prompt or model parameters

### Problem: "Out of memory"
**Solution:**
```python
# Process in smaller batches
batch_size = 10
for i in range(0, len(all_responses), batch_size):
    batch = all_responses[i:i+batch_size]
    batch_evaluate(batch, f'results_batch_{i}.jsonl')
```

### Problem: Rate limit errors
**Solution:**
```python
import time

# Add delay between evaluations
for response in responses:
    result = evaluate_response(...)
    time.sleep(1)  # Wait 1 second between calls
```

---

## Customization

### Change Confidence Threshold

```python
# In analyze_results() or your own analysis
threshold = 65  # Lower threshold = more human review
flagged = [r for r in results if r['evaluation_summary']['confidence'] < threshold]
print(f"Flagged for review: {len(flagged)} cases")
```

### Add Custom Metrics

```python
# Add new analysis functions
def calculate_false_negative_rate(results, ground_truth):
    fn = sum(1 for r, gt in zip(results, ground_truth) 
             if r['evaluation_summary']['total_score'] > 4 and gt['total_score'] < 3)
    return fn / len(results)
```

### Create Custom Visualizations

```python
# Add new plotting code
plt.figure(figsize=(12, 6))
plt.scatter(confidences, scores, alpha=0.6)
plt.xlabel('Confidence (%)')
plt.ylabel('Score (0-7)')
plt.title('Confidence vs Score')
plt.show()
```

---

## Best Practices

### 1. Version Control
Save different versions:
- `ai_judge_evaluation_v1.ipynb` - Original
- `ai_judge_evaluation_v2.ipynb` - With your modifications
- `ai_judge_evaluation_final.ipynb` - Final version for publication

### 2. Document Your Work
Add markdown cells explaining:
- Your study design
- Any modifications made
- Interesting findings
- Issues encountered

### 3. Regular Backups
- Save notebook frequently
- Export results regularly
- Keep copies of output files

### 4. Clean Output Before Sharing
Before sharing notebook:
- Kernel → Restart & Clear Output
- Remove API keys
- Remove any sensitive data

---

## Integration with Your Study

### Phase 1: Validation (Tier 1)

```python
# Load your 100 Tier 1 responses
tier1_data = pd.read_csv('tier1_responses.csv')

tier1_responses = [
    {
        'scenario_type': row['scenario_type'],
        'ai_response': row['response']
    }
    for _, row in tier1_data.iterrows()
]

# Evaluate with FULL version
tier1_results = batch_evaluate(
    tier1_responses,
    output_file='tier1_ai_judge.jsonl',
    version='full'
)

# Compare with human annotations
human_labels = pd.read_csv('tier1_human_labels.csv').to_dict('records')
comparison = compare_human_vs_ai(human_labels, tier1_results)

# Validate AI judge
if comparison['cohen_kappa'] > 0.85:
    print("✓ AI judge validated - proceed to Phase 2")
else:
    print("✗ AI judge needs improvement")
```

### Phase 2: Production (Tier 2-3)

```python
# Load remaining 300 responses
tier2_3_data = pd.read_csv('tier2_3_responses.csv')

# Switch to CONDENSED version
tier2_3_results = batch_evaluate(
    tier2_3_data.to_dict('records'),
    output_file='tier2_3_ai_judge.jsonl',
    version='condensed'
)

# Flag for human review
flagged = [r for r in tier2_3_results 
           if r['evaluation_summary']['needs_human_review']]
print(f"Flagged for review: {len(flagged)} cases")
```

---

## Output Files

The notebook creates these files:

| File | Description | Use |
|------|-------------|-----|
| `*.jsonl` | Raw evaluations | Archive, detailed analysis |
| `*_results.csv` | Tabular data | Excel, statistical software |
| `*_summary.json` | Statistics | Quick reference, reports |
| `*_detailed.json` | Full results | Reproducibility, sharing |

---

## Next Steps

1. **Test the notebook** with sample data
2. **Validate** on your Tier 1 dataset  
3. **Scale** to full 400 prompts
4. **Analyze** results for publication
5. **Export** for your papers

---

## Support

### Documentation Files
- `ai_judge_usage_guide.md` - Comprehensive workflow
- `prompt_version_comparison.md` - Full vs condensed
- `QUICK_REFERENCE.md` - One-page cheat sheet

### Common Issues
See Troubleshooting section above or check the usage guide for detailed solutions.

---

**Ready to start!** 🚀

Run cells 1-7 to test the system, then customize for your study.
