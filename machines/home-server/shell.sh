export CRYPTO_DATA_ROOT="/mnt/redbackup/data"
export CRYPTO_ARTIFACT_ROOT="/home/boser/crypto-data"
export RESEARCH_SCRATCH_ROOT="/home/boser/scratch/research-data"
export RESEARCH_ARCHIVE_ROOT="/mnt/redbackup/experiment-data"

# Each OMP session gets its own scope; at 8 GiB the kernel kills its largest
# process, without swapping first, and the scope keeps running the rest.
# No MemoryHigh: with swap off it stalls the session instead of killing.
alias omp='systemd-run --user --scope --quiet --collect -p MemoryMax=8G -p MemorySwapMax=0 -p OOMPolicy=continue omp'
