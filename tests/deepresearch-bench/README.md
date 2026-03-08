# DeepResearch-Bench Evaluation

Adapter and runner for evaluating our deep-research plugin against [DeepResearch-Bench](https://github.com/Ayanami0730/deep_research_bench), a benchmark of 100 PhD-level research tasks evaluated on two dimensions:

- **RACE**: Report quality across 4 dimensions (breadth, depth, relevance, coherence), scored by Gemini 2.5 Pro judge. Score of 50 = parity with reference articles.
- **FACT**: Citation accuracy — extracts URLs, deduplicates, scrapes pages, validates claims against sources.

## Setup

### 1. Clone the benchmark repo

```bash
git clone https://github.com/Ayanami0730/deep_research_bench.git
cd deep_research_bench
pip install -r requirements.txt
```

### 2. Set API keys

```bash
export GEMINI_API_KEY="..."   # Required for RACE (Gemini 2.5 Pro judge)
export JINA_API_KEY="..."     # Required for FACT (citation scraping)
```

### 3. Ensure `claude` CLI is installed and authenticated

The adapter invokes `claude -p` in non-interactive mode with our plugin.

## Running

### Step 1: Generate reports (adapter)

```bash
# Run on English tasks only (default), 3 concurrent
./tests/deepresearch-bench/adapter.sh \
  --bench-dir /path/to/deep_research_bench \
  --model opus \
  --output our-plugin

# Quick test: just 5 tasks
./tests/deepresearch-bench/adapter.sh \
  --bench-dir /path/to/deep_research_bench \
  --max 5

# All languages
./tests/deepresearch-bench/adapter.sh \
  --bench-dir /path/to/deep_research_bench \
  --lang all
```

### Step 2: Run evaluation

```bash
./tests/deepresearch-bench/run-bench.sh \
  --bench-dir /path/to/deep_research_bench \
  --model-name our-plugin
```

Results are saved to `tests/deepresearch-bench/results/`.

## Adapter options

| Flag           | Default      | Description                          |
|----------------|--------------|--------------------------------------|
| `--bench-dir`  | (required)   | Path to cloned bench repo            |
| `--model`      | `opus`       | Claude model name                    |
| `--output`     | `our-plugin` | Output filename (without .jsonl)     |
| `--lang`       | `en`         | Language filter: `en`, `zh`, `all`   |
| `--max`        | `0` (all)    | Limit number of tasks                |
| `--concurrent` | `3`          | Parallel task count                  |

## Citation handling

Our plugin produces `[n]` inline citations with a Sources appendix containing URLs. The adapter automatically converts these to `[Title](URL)` inline markdown links for FACT scoring compatibility, since FACT extracts and validates URLs from the article text.

## Cost and time estimates

- **Adapter**: Each task invokes a full deep-research session (~3-5 min per task with subagents). At 3 concurrent, 100 English tasks take roughly 2-4 hours. API cost depends on model — expect $50-150 for a full run on Opus.
- **RACE evaluation**: Calls Gemini 2.5 Pro for each task. Expect ~$5-10 and 30-60 min for 100 tasks.
- **FACT evaluation**: Scraping is the bottleneck. Jina API calls for each unique citation URL. Expect 1-2 hours for 100 tasks.

## Interpreting scores

| Metric | Meaning |
|--------|---------|
| RACE overall ~50 | Parity with Gemini 2.5 Pro reference articles |
| RACE >50 | Better than reference on that dimension |
| RACE <50 | Worse than reference |
| FACT citation accuracy | % of extracted citations that resolve to real, relevant content |
| FACT effective citations | Count of valid unique sources actually cited |
