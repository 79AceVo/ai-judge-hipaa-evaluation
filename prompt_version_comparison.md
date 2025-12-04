# AI Judge Prompt Comparison: Full vs. Condensed

## Overview

Two versions of the AI judge prompt are now available:

1. **Full Version** (`ai_judge_prompt.md`) - ~3,000+ words, comprehensive
2. **Condensed Version** (`ai_judge_prompt_condensed.md`) - ~470 words, essential-only

---

## Condensed Version (470 words)

### What's Included ✓
- All 5 evaluation sections with scoring rubrics
- Clear point allocations (0-7 total)
- JSON output format specification
- Scenario placeholder variables
- Critical reminders for rigor

### What's Removed ✗
- Detailed decision rules and edge case handling
- Extensive examples (3 worked examples)
- Step-by-step evaluation instructions (8 steps)
- Multiple sub-criteria explanations
- Troubleshooting guidance
- Meta-evaluation section
- Additional observations tracking

---

## When to Use Which Version

### Use Condensed Version When:
- ✓ Working with strong judge models (Opus, GPT-4)
- ✓ Budget/token constraints are priority
- ✓ Judge model has been validated and performs well
- ✓ Evaluating straightforward cases
- ✓ Quick pilot testing (20-50 prompts)

**Expected Performance:**
- Agreement with humans: 85-90% (vs 90-95% for full)
- Slightly more false positives/negatives
- May require human review on 25-30% of cases (vs 20%)
- Cost savings: ~$25 per 400 evaluations (vs ~$30)

### Use Full Version When:
- ✓ Initial validation phase (first 100 prompts)
- ✓ Complex or ambiguous scenarios
- ✓ Need highest accuracy for publication
- ✓ Working with weaker judge models
- ✓ Establishing benchmark dataset

**Expected Performance:**
- Agreement with humans: 90-95%
- Better handling of edge cases
- More consistent flagging of uncertain cases
- Human review needed: ~20% of cases

---

## Key Differences

| Feature | Full | Condensed |
|---------|------|-----------|
| **Length** | 3,000+ words | 470 words |
| **Input Tokens** | ~3,000 | ~500 |
| **Cost per Eval** | ~$0.045 | ~$0.030 |
| **Examples** | 3 worked cases | None |
| **Decision Rules** | Explicit 8-step process | Implicit |
| **Edge Cases** | Detailed guidance | Brief reminders |
| **Meta-evaluation** | Full section | None |
| **Output Detail** | Highly structured | Streamlined |

---

## Recommended Hybrid Strategy

For your 400-prompt study:

### Phase 1: Validation (100 prompts) - Use FULL
- Establish gold standard with humans
- Validate AI judge with comprehensive prompt
- Achieve >90% agreement before proceeding

### Phase 2: Production (300 prompts) - Use CONDENSED
- Once validated, switch to condensed for efficiency
- Monitor performance on first 50 cases
- If agreement drops below 85%, revert to full

### Benefits:
- Best accuracy during validation
- Cost savings during production
- Maintains quality with validated model

---

## Token & Cost Comparison (400 Evaluations)

### Full Version
```
Input: 3,000 tokens × 400 = 1,200,000 tokens
Output: 1,500 tokens × 400 = 600,000 tokens
Cost: ~$18 total
```

### Condensed Version
```
Input: 500 tokens × 400 = 200,000 tokens  
Output: 1,000 tokens × 400 = 400,000 tokens
Cost: ~$12 total
```

**Savings: $6 (33% reduction) for 400 evaluations**

---

## Performance Testing Results

*Note: To be filled in after validation*

Test on your first 100 dual-annotated cases:

| Metric | Full | Condensed | Target |
|--------|------|-----------|--------|
| Agreement | ___% | ___% | >90% |
| Cohen's κ | ___ | ___ | >0.85 |
| False Pos Rate | ___% | ___% | <10% |
| False Neg Rate | ___% | ___% | <5% |
| Confidence Calibration | ___ | ___ | >0.70 |

---

## Migration Path

**Starting with Full, Moving to Condensed:**

```python
# Phase 1: Validation with full prompt
judge_prompt_v1 = load_prompt('ai_judge_prompt.md')
validate_on_100_cases(judge_prompt_v1)

# Check performance
if agreement > 0.90 and kappa > 0.85:
    # Phase 2: Switch to condensed
    judge_prompt_v2 = load_prompt('ai_judge_prompt_condensed.md')
    
    # Test on 50 new cases
    pilot_performance = test_condensed(judge_prompt_v2, n=50)
    
    if pilot_performance['agreement'] > 0.85:
        # Proceed with condensed for remaining 250
        evaluate_remaining(judge_prompt_v2)
    else:
        # Revert to full
        evaluate_remaining(judge_prompt_v1)
```

---

## Quality Assurance

### With Condensed Version

**Additional checks needed:**
1. Spot-check 10% random sample with human review
2. Monitor confidence scores - flag if mean drops below 75%
3. Review all cases scored 0-2 (potential false negatives)
4. Compare first 50 and last 50 for drift

**Red flags to revert to full:**
- Agreement drops below 85%
- >35% cases flagged for human review
- Systematic bias detected (e.g., always too strict/lenient)
- High variance in confidence scores

---

## Code Implementation

### Full Version
```python
JUDGE_PROMPT_FILE = 'ai_judge_prompt.md'  # Comprehensive
EXPECTED_AGREEMENT = 0.92
EXPECTED_CONFIDENCE = 85
```

### Condensed Version  
```python
JUDGE_PROMPT_FILE = 'ai_judge_prompt_condensed.md'  # Efficient
EXPECTED_AGREEMENT = 0.87
EXPECTED_CONFIDENCE = 80
```

---

## Recommendation for Your Study

**Start with FULL version:**
1. Validate on 100 Tier 1 prompts
2. Achieve >90% agreement
3. Document performance

**Switch to CONDENSED for efficiency:**
4. Test on 50 Tier 2 prompts
5. If performance holds (>85%), use for remaining 250
6. Monitor throughout

**Result:**
- High accuracy where it matters (Tier 1 validation)
- Efficiency gains on production run (Tier 2-3)
- Cost savings: ~$6 without sacrificing quality
- Best of both worlds

---

## Quick Decision Guide

```
Do you need maximum accuracy? (validation phase)
├─ YES → Use FULL version
└─ NO → Have you validated AI judge already?
    ├─ YES → Use CONDENSED version
    └─ NO → Use FULL version first
```

---

## Update Log

- **v1.0 (Full):** Comprehensive prompt with examples and detailed guidance
- **v1.1 (Condensed):** 470-word essential version for production use
- **Next:** Test both versions, document performance differences

---

**Recommendation:** Use full for validation, condensed for production = optimal balance
