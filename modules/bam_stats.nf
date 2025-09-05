// bam_stats

nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process BAM_STATS {

	label 'error_retry'
    label 'process_medium'
    tag "$pair_id" // Adds name to job submission instead of (1), (2) etc.

    //cpus params.threads_bigmem
    scratch true


	container = 'https://depot.galaxyproject.org/singularity/mulled-v2-ac74a7f02cebcfcc07d8e8d1d750af9c83b4d45a:f70b31a2db15c023d641c32f433fb02cd04df5a6-0'


    input:
    tuple val(pair_id), path(mapped_bam), path(mapped_bam_idx)


    output:
    tuple val(pair_id), path("${pair_id}.sorted.bowtie2.bam.stats"),path("${pair_id}.sorted.bowtie2.bam.idxstats"), emit: bam_stats_ch

    script:

    def args = task.ext.args ?: ''


    """
    samtools sort -T ${pair_id} -o ${pair_id}.sorted.bowtie2.bam ${mapped_bam}
    samtools index ${pair_id}.sorted.bowtie2.bam -o ${pair_id}.sorted.bowtie2.bam.bai

	samtools idxstats {pair_id}.sorted.bowtie2.bam  >${pair_id}.sorted.bowtie2.bam.idxstats
	samtools stats {pair_id}.sorted.bowtie2.bam  >${pair_id}.sorted.bowtie2.bam.stats
    """

}


