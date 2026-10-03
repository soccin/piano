# IRIS SLURM settings for Forte (conf/eos.config)

Verified 2026-10-02, account `core001`, user `soccin`. Partition
membership and limits change without notice; re-verify with the commands
in the last section before trusting anything here. The full IRIS
reference lives in adagio (`docs/IRIS_SLURM.md`); this file records only
what Forte needs.

## Partitions core001 can use

| Partition      | Max time | Nodes | QoS allowed       | Notes                          |
|----------------|----------|-------|-------------------|--------------------------------|
| `cpushort`     | 2 h      | 232   | `normal` only     | general pool, 52 cpus/node max |
| `cmobic_short` | 3 h      | 37    | `normal,priority` | group hardware                 |
| `cmobic_cpu`   | 7 d      | 19    | `normal,priority` | group hardware                 |

- `cpushort` and `cmobic_short` node sets are disjoint. A task that fits
  in 2 h and names both can land on 269 nodes. Over 2 h it has 37 nodes;
  over 3 h it has 19.
- SLURM validates walltime against the most restrictive partition named,
  so a 3 h request must name `cmobic_short` alone.
- `--qos=priority` on any request that includes `cpushort` is rejected
  with `Invalid qos specification`. The config sends an explicit
  `--qos=normal` with every `cpushort` request rather than relying on the
  association default (`DefaultQOS` is unset for `core001`, so the
  cluster default applies today). sbatch lets `SBATCH_*` environment
  variables override `#SBATCH` lines, so an exported `SBATCH_QOS` or
  `SBATCH_PARTITION` would silently rewrite every task; `runForte.sh`
  unsets them on IRIS. Nothing in the shell startup files or the
  `~/bin/sbatch` wrapper sets them; adagio's incident came from a hand
  exported `SBATCH_QOS=priority`.
- `/localscratch` exists and is world-writable on all three partitions.
  Nextflow creates `/localscratch/core001/soccin` itself (`mkdir -p` in
  `nxf_mktemp`), so the `scratch` setting works on general-pool nodes.
  Checked by probe jobs on isca085 (cpushort), isca236 (cmobic_short),
  isca227 (cmobic_cpu).

## Scheme

Ported from adagio `conf/tempo-wes-iris.config`.

Each process has a ladder of (queue, time) rungs. Attempt 1 takes rung
0. On a retry, `tierFor` reads the previous attempt's requested time
from `task.previousTrace.time`, finds that rung in the ladder, and moves
up one rung only if the previous attempt ran to within 5 min of its cap
(`task.previousTrace.realtime`). Any other failure (exit 1, OOM, node
loss) retries in the same rung at every attempt. Memory still ramps with
`task.attempt`, so an OOM retry gets more memory where it is. If the
previous time matches no rung (a `-resume` across a config change) the
fallback assumes every earlier attempt was promoted.

- Default ladder: `cpushort,cmobic_short` 2 h (`--qos=normal`), then
  `cmobic_cpu` 24 h (`--qos=priority`).
- `STAR_ALIGN` and `STAR_FOR_STARFUSION`: 16 cpus, 96 GB x attempt,
  three rungs: 2 h short, 3 h `cmobic_short`, 24 h `cmobic_cpu`. A 2 h
  wall kill goes to the 3 h rung first, not to `cmobic_cpu`.
- `FUSIONCATCHER_DETECT`: 24 cpus, 96 GB x attempt, starts on
  `cmobic_short` at 3 h, promotes to `cmobic_cpu` at 24 h.
- Driver (`runForte.sh`): `cmobic_cpu`, `--qos=priority`, 7 d.

Every `withLabel` block sets `time`: forte's `conf/base.config` defines
a per-label time and a `withLabel` directive overrides the process-level
default. The previous `eos.config` had a second `withLabel:process_low`
block (meant to be `process_long`) that gave every `process_low` task a
50 h request.

Checked 2026-10-02 with a local-executor run of the real config (ladder
times shrunk to seconds): `task.previousTrace.realtime` and
`task.previousTrace.time` are both milliseconds on Nextflow 25.10, a
wall-killed attempt still records its realtime, two fast exit-1 failures
leave attempt 3 on rung 0 for all three ladders, a wall kill promotes one
rung, and `qosFor` sees the resolved `task.queue`.

To land this on a checkout that already ran `00.SETUP.sh`, copy
`conf/eos.config` over `forte/conf/eos.config` by hand; setup only
copies it once.

## Forte timing data

15 Forte runs on IRIS (2025-06 to 2026-07, 1 to 12 samples each),
1185 completed tasks, from `pipeline_info/*/execution_trace.txt` under
`Users/ElenitK/BermeoJ/Proj_*`. Regenerate with:

```
Rscript R/forteTraceSummary.R OUT_PREFIX trace1.txt trace2.txt ...
```

The script writes `OUT_PREFIX.summary.tsv` (one row per process and
requested cpu count, with completed/failed/aborted counts) and
`OUT_PREFIX.tasks.tsv`; this table is copied from the summary by hand.
Quantiles are over completed tasks only, so once the short caps are
live, read `<2h`/`<3h` together with the failed count: wall-killed
attempts are FAILED rows, not slow COMPLETED rows.

Times in hours, memory is peak RSS in GB, cpus as requested.

| Process                   |  n | cpus  | rt p50 | rt p90 | rt max | <2h | <3h | rss p50 | rss p95 | rss max |
|---------------------------|---:|-------|-------:|-------:|-------:|----:|----:|--------:|--------:|--------:|
| FUSIONCATCHER_DETECT      | 33 | 12    |   2.30 |   3.12 |   7.38 | 36% | 82% |    24.1 |    56.5 |    63.7 |
| FUSIONCATCHER_DETECT      |  2 | 24    |   4.45 |        |   6.58 |  0% | 50% |    55.4 |         |    75.7 |
| STAR_ALIGN                | 34 | 12    |   0.57 |   1.31 |   2.08 | 94% |100% |    36.1 |    37.2 |    37.6 |
| STAR_FOR_STARFUSION       | 35 | 12    |   0.50 |   1.26 |   1.48 |100% |100% |    39.2 |    40.3 |    40.5 |
| PICARD_COLLECTRNASEQMETRICS | 34 | 1   |   0.40 |   0.81 |   1.04 |100% |100% |     2.6 |     2.8 |     2.9 |
| FEATURECOUNTS_GENE        | 34 | 6     |   0.04 |   0.16 |   0.93 |100% |100% |     0.5 |     0.5 |     0.5 |
| ARRIBA_ARRIBA             | 34 | 6     |   0.12 |   0.35 |   0.86 |100% |100% |    12.3 |    29.1 |    33.0 |
| STARFUSION                | 35 | 6     |   0.16 |   0.32 |   0.53 |100% |100% |     4.0 |     4.1 |     4.1 |
| RSEQC_READDUPLICATION     | 33 | 6     |   0.17 |   0.33 |   0.44 |100% |100% |    15.8 |    33.1 |    44.2 |
| RSEQC_READDUPLICATION     |  1 | 12    |   0.45 |        |   0.45 |100% |100% |    57.5 |         |    57.5 |
| RSEQC_JUNCTIONSATURATION  | 34 | 6     |   0.12 |   0.25 |   0.38 |100% |100% |     4.4 |     9.0 |    13.9 |
| PORTCULLIS_FULL           | 34 | 12    |   0.05 |   0.22 |   0.33 |100% |100% |     8.9 |    23.7 |    35.3 |
| KALLISTO_QUANT            | 35 | 12    |   0.17 |   0.25 |   0.31 |100% |100% |     5.0 |     5.2 |     5.3 |
| FASTP                     | 95 | 6     |   0.03 |   0.08 |   0.26 |100% |100% |     2.5 |     3.2 |     4.5 |
| all other processes       |    |       |        |        | < 0.5  |100% |100% |         |         |  < 7    |

Failures on record (7 FAILED tasks; the 24 ABORTED tasks are from a run
that was stopped by hand):

- `RSEQC_READDUPLICATION` OOM at 48 GB (exit 137) once; retry at 96 GB
  finished in 27 min with 57.5 GB peak. The x attempt memory ramp covers
  this without leaving the short queue.
- `FUSIONCATCHER_DETECT` exit 1 twice after 1.2 h and 1.6 h, far from
  any walltime; both retries completed at 24 cpus, in 2.3 h and 6.6 h.
  Work directories are gone, cause unknown. The ladder retries these in
  the same rung.
- `STAR_ALIGN` exit 1 four times on one sample in Proj_15672 with
  resources doubling each attempt (12 to 48 cpus, 96 to 384 GB); none
  helped. Not a resource problem.

## Decisions and the evidence behind them

- Default rung 2 h: every process but FusionCatcher has p90 under 1.4 h.
- Long rung 24 h, not 7 d: longest Forte task on record is 7.4 h. A 24 h
  request can still be backfilled; a 7 d one holds cores if a task
  wedges.
- STAR 12 to 16 cpus: STAR ran at 900 to 1100% of its 1200% allocation,
  so it uses the cores it gets. The two tasks over 2 h (2.05 h, 2.08 h)
  should drop to about 1.6 h. Peak RSS is a tight 36 to 41 GB and does
  not depend on threads, so memory stays at 96 GB.
- FusionCatcher straight to `cmobic_short` at 3 h: a 2 h attempt would
  be wasted on two thirds of samples. 82% finish in 3 h at 12 cpus
  (p90 3.12 h).
- FusionCatcher 12 to 24 cpus: median %cpu was 460% at 12 cpus and 845
  to 865% on the two retries that ran at 24 cpus, so the parallel phases
  do scale. Those two retries took 2.3 h and 6.6 h on different samples
  whose first attempts failed with exit 1, so there is no same-sample
  comparison; the expected gain (the 2 to 3.1 h band moving under 3 h)
  is a projection. Check the first run.
- FusionCatcher memory 96 GB x attempt: peak RSS p95 57 GB and max 64 GB
  at 12 cpus; 76 GB on one 24 cpu retry.

## Re-verify

The `--test-only` lines mirror what the task scripts request: default
rung with the 16 cpu STAR shape, FusionCatcher on `cmobic_short`, a
fourth-attempt `process_high` task (48 cpus, 384 GB) on both the short
pair and the long queue. All passed on 2026-10-02.

```
sinfo -h -o "%P|%l|%D" | sort -u
scontrol show partition cpushort
sacctmgr -n -P show assoc user=$USER format=Cluster,Account,Partition,QOS,DefaultQOS
env | grep ^SBATCH_
sbatch --test-only -A core001 -p cpushort,cmobic_short --qos=normal -t 02:00:00 -c 16 --mem 96G --wrap="true"
sbatch --test-only -A core001 -p cpushort,cmobic_short --qos=normal -t 02:00:00 -c 48 --mem 384G --wrap="true"
sbatch --test-only -A core001 -p cmobic_short --qos=priority -t 03:00:00 -c 24 --mem 96G --wrap="true"
sbatch --test-only -A core001 -p cmobic_cpu --qos=priority -t 24:00:00 -c 48 --mem 384G --wrap="true"
```
