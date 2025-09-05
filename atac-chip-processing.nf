/* 
 * Pipeline for processing of ChIP-seq and ATAC-seq data
 * includes basic QC steps
 * Written for NBIS Epigenomics Workshop
 * 
 * Author: Agata Smialowska
 * August 2025
 */ 




nextflow.enable.dsl=2


/* 
 * pipeline input parameters 
 */
params.resdir = "results"
params.projdir = "$launchDir/${params.projname}"

params.outdir = "${params.projdir}/${params.resdir}"

params.logdir = 'logs'


params.fastqPE="${params.fastqdir}/*_{1,2}.fastq.gz" // SRA file naming convention
params.fastq="${params.fastqdir}/*fastq.gz"





log.info """\
 ATAC ChIP processing pipeline
 ===================================
 fastq files directory: ${params.fastqdir}
 reference genome: ${params.genomeFa}
 outdir       : ${params.outdir}

 """
 .stripIndent()

println ""


/////////////////////////////
// channels

//fastq files channel for PE
read_pairs = Channel.fromFilePairs(params.fastqPE, checkIfExists: true )
	read_pairs
	    .view()
	    .set { read_pairs }



// fastq file paths channel - paths
fastq_ch= Channel.fromPath(params.fastq , checkIfExists:true)
	fastq_ch
	    //.view()
	    .set { fastq_ch }


// fa for index
fa_ch=Channel.fromPath(params.genomeFa , checkIfExists:true)


// blacklists
blacklist_ch= Channel.fromPath(params.blacklist, checkIfExists:true)
	blacklist_ch
		//.view()
		.set { blacklist_ch }


//idx_bowtie_ch=Channel.fromPath(params.idx_pth, checkIfExists:true)


/////////////////////////////
// processes
include { FASTQC_RAW     } from "$projectDir/modules/fastqc_raw.nf"
include { TRIM_READS_PE          } from "$projectDir/modules/trim_reads.nf"
include { FASTQC_TRIMMED           } from "$projectDir/modules/fastqc_trimmed.nf"
include { IDX_GENOME            } from "$projectDir/modules/idx_genome.nf"
include { GENOME_BLACKLIST_REGIONS } from "$projectDir/modules/genome_noblcklst.nf"
include { MAP_READS_GENOME      } from "$projectDir/modules/map_reads_genome.nf"
include { BAM_STATS            } from "$projectDir/modules/bam_stats.nf"
include { BAM_PAIRED_FILT } from "$projectDir/modules/bam_file_pp.nf"
include { BAM_FILT        } from "$projectDir/modules/filt_bam.nf"
include { BAM_DEDUP            } from "$projectDir/modules/dedup_bam.nf"
include { BAM_STATS2 } from "$projectDir/modules/bam_stats2.nf"
include { BAM_FINGERPRINT        } from "$projectDir/modules/bam_fingerprint.nf"
include { BAM_COVERAGE        } from "$projectDir/modules/bam_coverage.nf"
include { BAM_FINGERPRINT2       } from "$projectDir/modules/bam_fingerprint2.nf"
include { BAM_CORRELATION       } from "$projectDir/modules/bam_clustering.nf"
include { BAM_FRAG_LEN } from "$projectDir/modules/bam_fragmentsize.nf"
include { BAM_SORT } from "$projectDir/modules/sort_bam.nf"




/////////////////////////////
// workflows

//default non subset files

workflow {

	//QC
	FASTQC_RAW(fastq_ch)

	TRIM_READS_PE(read_pairs)

	trimmed_reads_PE_ch=TRIM_READS_PE.out.trimmed_reads_ch

	FASTQC_TRIMMED(trimmed_reads_PE_ch)

	//genome index
	IDX_GENOME(fa_ch)

	GENOME_BLACKLIST_REGIONS(fa_ch, IDX_GENOME.out.chromsizes_ch, blacklist_ch)

	//read mapping
	idx_bowtie_ch=IDX_GENOME.out.idx_bowtie_ch
		idx_bowtie_ch
			.flatten()
			.collect()
			.map{[it]}
			//.view()
			.set{ idx_bowtie_ch }


	map_readsPE_ch=TRIM_READS_PE.out.trimmed_reads_ch
		map_readsPE_ch
			.combine(idx_bowtie_ch)
			//.view()
			.set {map_readsPE_ch}

	MAP_READS_GENOME(map_readsPE_ch)

	BAM_SORT(MAP_READS_GENOME.out.mappedPE_ch)

	BAM_STATS(BAM_SORT.out.bam_sorted_ch)


	//post processing

	BAM_PAIRED_FILT(BAM_SORT.out.bam_sorted_ch)

	BAM_DEDUP(BAM_PAIRED_FILT.out.bam_ch)

	BAM_FILT(BAM_DEDUP.out.bam_dedup_ch, GENOME_BLACKLIST_REGIONS.out.noblcklst_bed_ch.first())
	
	BAM_STATS2(BAM_FILT.out.bam_filt_ch)

	BAM_COVERAGE(BAM_FILT.out.bam_filt_ch)

	// QC
	BAM_FINGERPRINT(BAM_FILT.out.bam_filt_ch)

	ch_all_bams=BAM_FILT.out.bam_filt_ch
		ch_all_bams
			//.view()
			//.filter( ~/bam$/ )
			//.collect()
			.map { it[1] }
			.collect()
			.view()
			.set {ch_all_bams}

	ch_all_bais=BAM_FILT.out.bam_filt_ch
		ch_all_bais
			//.view()
			//.filter( ~/bam$/ )
			//.collect()
			.map { it[2] }
			.collect()
			.view()
			.set {ch_all_bais}

	BAM_FINGERPRINT2(ch_all_bams,ch_all_bais)

	BAM_CORRELATION(ch_all_bams,ch_all_bais)

	BAM_FRAG_LEN(BAM_FILT.out.bam_filt_ch)

}

