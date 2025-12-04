# Practical Guide: Using AI Judge for Hybrid HIPAA Evaluation

## Quick Reference

**Files Created:**
1. `ai_judge_prompt.md` - Complete evaluation prompt for AI judge
2. `ai_judge_implementation.py` - Python code to run evaluations
3. This guide - Step-by-step usage instructions

**Purpose:** Evaluate AI responses for HIPAA compliance using a hybrid human + AI approach

---

## Study Design Overview

### Your 400-Prompt Study Structure

**Stratified Hybrid Approach:**
- **Tier 1 (100 prompts):** Critical cases → Full dual evaluation (human + AI judge)
- **Tier 2 (200 prompts):** Standard variations → AI judge + 30% human review (60 prompts)
- **Tier 3 (100 prompts):** Control cases → AI judge + 20% human review (20 prompts)

**Total human annotation: 180 prompts (45%)**
**Total AI judge evaluation: 400 prompts (100%)**

---

## Step-by-Step Workflow

### Phase 1: Setup (Week 1)

**1. Prepare Your Dataset**

Create a CSV with your 400 prompts:
```csv
prompt_id,tier,scenario_type,prompt_text,expected_behavior
001,tier1,scenario_1_authorization,"Can I share...",AI should identify...
002,tier1,scenario_2_minimum_necessary,"What insurance...",AI should flag...
...
```

**2. Collect Target AI Responses**

Run all 400 prompts through your operational AI chatbot:
```python
responses = []
for prompt in prompts_df.itertuples():
    response = operational_ai.chat(prompt.prompt_text)
    responses.append({
        'prompt_id': prompt.prompt_id,
        'tier': prompt.tier,
        'scenario_type': prompt.scenario_type,
        'prompt': prompt.prompt_text,
        'ai_response': response
    })
```

**3. Configure AI Judge**

Update `ai_judge_implementation.py`:
```python
API_KEY = "your-anthropic-api-key"
JUDGE_MODEL = "claude-opus-4-20250514"  # Most capable model
```

---

### Phase 2: Tier 1 - Validation Set (Weeks 2-3)

**Goal:** Create gold standard + validate AI judge

**Step 1: Human Annotation (100 prompts)**

Distribute to 2 annotators:
- Each annotates all 100 independently
- Use the evaluation criteria checklist
- Track time per annotation
- Flag difficult cases

**Step 2: Calculate Inter-Rater Reliability**

```python
from sklearn.metrics import cohen_kappa_score

# After both annotators finish
kappa = cohen_kappa_score(annotator1_scores, annotator2_scores)
print(f"Cohen's Kappa: {kappa:.3f}")

# Target: κ > 0.80 for HIPAA
# If κ < 0.75, hold calibration meeting and re-annotate sample
```

**Step 3: Adjudicate Disagreements**

- Review ~20-30 cases where annotators disagree
- Discuss reasoning
- Reach consensus
- Document decision patterns

**Step 4: Run AI Judge on Same 100**

```python
from ai_judge_implementation import batch_evaluate

# Evaluate Tier 1 with AI judge
tier1_responses = [r for r in responses if r['tier'] == 'tier1']

ai_evaluations = batch_evaluate(
    responses=tier1_responses,
    output_file='tier1_ai_judge_results.jsonl'
)
```

**Step 5: Validate AI Judge Performance**

```python
from ai_judge_implementation import compare_human_vs_ai

comparison = compare_human_vs_ai(
    human_labels_file='tier1_human_labels.jsonl',
    ai_labels_file='tier1_ai_judge_results.jsonl'
)

print(f"Agreement Rate: {comparison['compliance_agreement']['percentage']:.1f}%")
print(f"Cohen's Kappa: {comparison['cohen_kappa']:.3f}")

# Target: Agreement > 90%, Kappa > 0.85
# If below target, refine judge prompt and iterate
```

**Step 6: Analyze Disagreements**

```python
# Identify where human and AI judge disagree
disagreements = []
for i in range(len(human_labels)):
    if human_labels[i]['compliance'] != ai_labels[i]['compliance']:
        disagreements.append({
            'prompt_id': prompts[i]['prompt_id'],
            'human_score': human_labels[i]['total_score'],
            'ai_score': ai_labels[i]['total_score'],
            'reason': analyze_disagreement(human_labels[i], ai_labels[i])
        })

# Review patterns - does AI judge consistently miss certain error types?
```

**Decision Point:**
- ✓ If agreement >90%: Proceed to Phase 3
- ✗ If agreement <85%: Refine prompt, re-run, validate again

---

### Phase 3: Tier 2 & 3 - Scaled Evaluation (Week 4)

**Goal:** Use validated AI judge with selective human oversight

**Step 1: Run AI Judge on All 300 Remaining Prompts**

```python
tier2_3_responses = [r for r in responses if r['tier'] in ['tier2', 'tier3']]

ai_evaluations = batch_evaluate(
    responses=tier2_3_responses,
    output_file='tier2_3_ai_judge_results.jsonl'
)
```

**Step 2: Identify Cases Needing Human Review**

```python
# Load AI judge results
import json

flagged_for_review = []
with open('tier2_3_ai_judge_results.jsonl', 'r') as f:
    for line in f:
        eval_result = json.loads(line)
        
        # Flag if confidence < 70% OR marked for human review
        if (eval_result['evaluation_summary']['confidence'] < 70 or 
            eval_result['evaluation_summary']['needs_human_review']):
            flagged_for_review.append(eval_result)

print(f"Flagged for human review: {len(flagged_for_review)} cases")
# Expected: ~60-90 cases (20-30% of 300)
```

**Step 3: Stratified Sampling for Human Review**

```python
import random

# Tier 2: Sample 30 from 200 (if not flagged, take random sample)
tier2_flagged = [f for f in flagged_for_review if f['metadata']['tier'] == 'tier2']
tier2_sample_size = 30 - len(tier2_flagged)
tier2_random = random.sample(
    [r for r in tier2_results if r not in tier2_flagged], 
    tier2_sample_size
)
tier2_human_review = tier2_flagged + tier2_random

# Tier 3: Sample 20 from 100
tier3_flagged = [f for f in flagged_for_review if f['metadata']['tier'] == 'tier3']
tier3_sample_size = 20 - len(tier3_flagged)
tier3_random = random.sample(
    [r for r in tier3_results if r not in tier3_flagged],
    tier3_sample_size
)
tier3_human_review = tier3_flagged + tier3_random

# Total for human review: 50 + random sample
human_review_batch = tier2_human_review + tier3_human_review
print(f"Total for human review: {len(human_review_batch)}")
```

**Step 4: Human Review of Flagged/Sampled Cases**

Annotators review ~80 cases:
- Focus extra attention on AI-flagged uncertain cases
- Use same evaluation criteria
- Note if they agree/disagree with AI judge

**Step 5: Quality Assurance Check**

```python
# Compare human review of sampled cases to AI judge
sampled_comparison = compare_human_vs_ai(
    human_labels_file='tier2_3_human_sample.jsonl',
    ai_labels_file='tier2_3_ai_judge_results.jsonl'
)

print(f"QA Agreement: {sampled_comparison['compliance_agreement']['percentage']:.1f}%")

# If agreement drops below 85%, may need to expand human review
```

---

### Phase 4: Final Analysis (Week 5)

**Step 1: Combine All Results**

```python
all_results = {
    'tier1': {
        'human_labels': load_json('tier1_human_labels.jsonl'),
        'ai_labels': load_json('tier1_ai_judge_results.jsonl'),
        'coverage': '100% dual annotation'
    },
    'tier2': {
        'human_labels': load_json('tier2_human_sample.jsonl'),
        'ai_labels': load_json('tier2_ai_judge_results.jsonl'),
        'coverage': '30% human, 100% AI'
    },
    'tier3': {
        'human_labels': load_json('tier3_human_sample.jsonl'),
        'ai_labels': load_json('tier3_ai_judge_results.jsonl'),
        'coverage': '20% human, 100% AI'
    }
}
```

**Step 2: Calculate Overall Compliance Rates**

```python
# For prompts with human labels, use those
# For prompts without human labels, use AI judge (validated)

overall_scores = []
for tier in ['tier1', 'tier2', 'tier3']:
    # Use human labels where available
    for label in all_results[tier]['human_labels']:
        overall_scores.append(label['total_score'])
    
    # Use AI labels for rest (weighted by validation confidence)
    # ... implementation details

compliance_rate = sum(s >= 5 for s in overall_scores) / len(overall_scores)
print(f"Overall HIPAA Compliance Rate: {compliance_rate:.1%}")
```

**Step 3: Analyze by Scenario Type**

```python
scenario1_scores = [s for s in scores if s['scenario_type'] == 'scenario_1_authorization']
scenario2_scores = [s for s in scores if s['scenario_type'] == 'scenario_2_minimum_necessary']

print(f"Scenario 1 (Authorization) Compliance: {mean(scenario1_scores):.2f}/7")
print(f"Scenario 2 (Minimum Necessary) Compliance: {mean(scenario2_scores):.2f}/7")

# Test for significant difference
from scipy.stats import ttest_ind
t_stat, p_value = ttest_ind(scenario1_scores, scenario2_scores)
print(f"Difference significant: p = {p_value:.3f}")
```

**Step 4: Failure Mode Analysis**

```python
# From error categorization
errors_by_type = {
    'missed_violation': 0,
    'incorrect_interpretation': 0,
    'over_refusal': 0
}

for result in all_results['tier1']['human_labels']:
    if result['compliance_rating'] == 'Non-Compliant':
        for error in result['errors_identified']:
            errors_by_type[error] += 1

print("\nMost Common Failure Modes:")
for error_type, count in sorted(errors_by_type.items(), key=lambda x: x[1], reverse=True):
    print(f"  {error_type}: {count} cases")
```

**Step 5: AI Judge Performance Report**

```python
# Across all tiers with human labels (180 total)
final_comparison = compare_human_vs_ai(
    human_labels_file='all_human_labels.jsonl',
    ai_labels_file='all_ai_judge_results.jsonl'
)

print("\n=== AI JUDGE VALIDATION REPORT ===")
print(f"Total Compared: {final_comparison['total_compared']}")
print(f"Exact Score Agreement: {final_comparison['exact_score_agreement']['percentage']:.1f}%")
print(f"Compliance Agreement: {final_comparison['compliance_agreement']['percentage']:.1f}%")
print(f"Cohen's Kappa: {final_comparison['cohen_kappa']:.3f}")
print(f"\nConclusion: AI judge is {'VALIDATED' if final_comparison['cohen_kappa'] > 0.85 else 'NEEDS REFINEMENT'}")
```

---

## Cost & Time Estimates

### API Costs (Anthropic)

**Judge Model: Claude Opus 4**
- Input: ~3,000 tokens per evaluation (prompt template + scenario + response)
- Output: ~1,500 tokens per evaluation (structured JSON)
- Cost per evaluation: ~$0.045

**Total for 400 prompts:**
- 400 evaluations × $0.045 = **$18**

**Including iterative refinement:**
- Validation iterations: ~$10
- **Total API cost: ~$30**

### Human Time Investment

| Activity | Prompts | Time per Prompt | Total Time |
|----------|---------|-----------------|------------|
| **Phase 2: Tier 1** |
| Annotation (2 annotators) | 100 | 6 min | 20 hours |
| Adjudication | 25 | 15 min | 6 hours |
| AI judge validation | - | - | 4 hours |
| **Phase 3: Tier 2 & 3** |
| Selective human review | 80 | 6 min | 8 hours |
| **Phase 4: Analysis** |
| Data analysis | - | - | 12 hours |
| **Total** | **180 human** | - | **50 hours** |

### Timeline

- Week 1: Setup and data collection
- Week 2-3: Tier 1 annotation + AI judge validation
- Week 4: Tier 2-3 evaluation + selective review
- Week 5: Final analysis
- **Total: 5 weeks**

---

## Quality Control Checklist

### Before Starting
- [ ] All 400 prompts finalized and categorized by tier
- [ ] Target AI responses collected
- [ ] Two HIPAA expert annotators recruited
- [ ] Annotation platform/spreadsheet set up
- [ ] AI judge implementation tested on 5 sample cases

### During Phase 2 (Validation)
- [ ] Inter-rater reliability κ > 0.80
- [ ] Adjudication completed for disagreements
- [ ] AI judge agreement with humans > 90%
- [ ] AI judge confidence scores calibrated
- [ ] Disagreement patterns documented

### During Phase 3 (Scaled Evaluation)
- [ ] Flagging thresholds validated (confidence < 70%)
- [ ] Stratified sampling executed correctly
- [ ] Human reviewers focused on flagged cases
- [ ] QA sample confirms maintained accuracy

### Before Publication
- [ ] All human annotations have inter-rater reliability metrics
- [ ] AI judge performance fully validated and reported
- [ ] Failure modes analyzed and documented
- [ ] Statistical tests for significance completed
- [ ] Method limitations acknowledged

---

## Troubleshooting

### Problem: Low Inter-Rater Reliability (κ < 0.75)

**Solutions:**
1. Hold calibration meeting with annotators
2. Clarify ambiguous criteria (e.g., when to mark "Ambiguous")
3. Review 10 cases together and discuss reasoning
4. Re-annotate sample and recalculate κ

### Problem: AI Judge Agreement < 85%

**Solutions:**
1. Analyze disagreement patterns - where does AI fail?
2. Refine judge prompt with more examples
3. Add few-shot examples from Tier 1 disagreements
4. Consider using stronger model (Opus vs Sonnet)
5. Re-validate on subset before proceeding

### Problem: Too Many Cases Flagged for Human Review (>40%)

**Solutions:**
1. Increase confidence threshold (try 60% instead of 70%)
2. Review what makes AI uncertain - refine prompt
3. Accept higher human review burden for critical domain
4. Consider this a feature, not bug (better safe than sorry)

### Problem: AI Judge Shows Systematic Bias

**Examples:**
- Always scores minimum necessary higher than authorization
- Consistently more lenient/strict than humans
- Misses specific error type

**Solutions:**
1. Document the bias clearly
2. Apply correction factor if consistent
3. Use only for pre-screening, not final labels
4. Expand human review in biased areas

---

## Output Files for Publication

### For Methods Section

**File: `evaluation_methodology.md`**
- Detailed annotation protocol
- Inter-rater reliability results
- AI judge validation metrics
- Justification for hybrid approach

### For Results Section

**File: `compliance_results.csv`**
```csv
prompt_id,tier,scenario_type,total_score,compliance_rating,risk_level,label_source
001,tier1,scenario_1,6,Fully Compliant,No Risk,human
002,tier1,scenario_2,3,Non-Compliant,Medium Risk,human
...
```

**File: `ai_judge_performance.json`**
```json
{
  "validation_set_size": 180,
  "agreement_metrics": {
    "exact_score_agreement": 0.89,
    "compliance_agreement": 0.92,
    "cohen_kappa": 0.87
  },
  "confidence_calibration": {
    "mean_confidence": 82.5,
    "confidence_accuracy_correlation": 0.73
  }
}
```

### For Supplementary Materials

**File: `annotated_examples.json`**
- 10-20 exemplar cases with full annotation
- Shows diversity of responses
- Documents difficult edge cases

**File: `disagreement_analysis.md`**
- Cases where humans disagreed
- Cases where AI judge disagreed with humans
- Lessons learned

---

## Tips for Success

### 1. Start with Pilot
Test on 20 cases before full study:
- Calibrate annotators
- Validate AI judge
- Estimate timing
- Refine criteria if needed

### 2. Document Everything
- Keep detailed logs of changes
- Note all calibration meetings
- Save all versions of prompts
- Track time spent per task

### 3. Communicate Clearly
With annotators:
- Provide written guidelines
- Hold regular check-ins
- Address questions quickly
- Share interesting cases

### 4. Plan for Disagreements
- Budget extra time for adjudication
- Don't force consensus - some cases are genuinely ambiguous
- Use disagreements to improve criteria

### 5. Be Conservative
- When uncertain, score lower (HIPAA is high-stakes)
- Flag for human review when in doubt
- Better to over-annotate than under-annotate

---

## Next Steps After Evaluation

1. **Write up results** for both papers:
   - Paper 1: HIPAA compliance findings
   - Paper 2: Evaluation methodology

2. **Release dataset** (if possible):
   - 400 prompts
   - 180 human labels
   - 400 AI judge evaluations
   - Becomes benchmark for future research

3. **Share AI judge prompt**:
   - Enable replication
   - Allow others to validate
   - Contribute to research community

4. **Iterate on framework**:
   - Use findings to improve operational AI
   - Refine Sentinel AI based on failure modes
   - Close the learning loop

---

## Contact & Support

**For questions about:**
- Evaluation criteria: See `evaluation_criteria_assessment.md`
- AI judge prompt: See `ai_judge_prompt.md`
- Implementation: See `ai_judge_implementation.py`
- This guide: You're reading it!

**Need help?** Review troubleshooting section or flag specific issues during your study.

Good luck with your evaluation! 🎯
