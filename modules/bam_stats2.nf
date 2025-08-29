// bam_stats

nextflow.enable.dsl=2
params.local = ''


// versions
params.verfile="software.versions"


process BAM_STATS2 {

	label 'error_retry'
    label 'process_low'
    tag "$pair_id" // Adds name to job submission instead of (1), (2) etc.

    //cpus params.threads_bigmem
    scratch true


	container = 'https://depot.galaxyproject.org/singularity/mulled-v2-ac74a7f02cebcfcc07d8e8d1d750af9c83b4d45a:f70b31a2db15c023d641c32f433fb02cd04df5a6-0'


    input:
    tuple val(pair_id), path(mapped_bam)


    output:
    tuple val(pair_id), path("${pair_id}.sorted.bowtie2.bam.stats"),path("${pair_id}.sorted.bowtie2.bam.idxstats"), emit: bam_stats_ch
    //path("${mapped_bam}.bai"), emit: bai_dedup_ch
    tuple val(pair_id), path("${mapped_bam}.bai"), emit: bai_dedup_ch
    //tuple val(pair_id), path("${mapped_bam}"), emit: bam_dedup_ch
	tuple val(pair_id), path("${mapped_bam}"), path("${mapped_bam}.bai"), emit: bam_bai_smpl_dedup_ch

    script:

    def args = task.ext.args ?: ''


    """
    samtools index ${mapped_bam} -o ${mapped_bam}.bai
	samtools idxstats ${mapped_bam}  >${pair_id}.sorted.bowtie2.bam.idxstats
	samtools stats ${mapped_bam}  >${pair_id}.sorted.bowtie2.bam.stats
    """

}


