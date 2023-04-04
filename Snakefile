import re

configfile: 'config.yml'
    
wildcard_constraints:
    app='hippunfold',
    hemi='L|R',
    subject='[a-zA-Z0-9]+',


def get_zip_file(wildcards):
    """ assuming we have zipfiles named as:  sub-{subject}_<...>.zip, 
        e.g.  diffparc.zip 
    """
    return config['in_zip'][wildcards.app]


(subjects,hemis,raters)= glob_wildcards(config['manual_seg'])

rule all:
    input:
        expand('results/sub-{subject}_hemi-{hemi}_rater-{rater}_vis.sh',zip,subject=subjects,hemi=hemis,rater=raters),
        expand('results/sub-{subject}_hemi-{hemi}_desc-tissue_vis.sh',zip,subject=subjects,hemi=hemis,rater=raters),
        expand('results/sub-{subject}_hemi-{hemi}_desc-subfields_vis.sh',zip,subject=subjects,hemi=hemis,rater=raters)

rule get_from_zip:
    """ This is a generic rule to make any file within the {app} subfolder, 
        by unzipping it from a corresponding zip file"""
    input:
        zip=get_zip_file
    output:
        '{app}/{file}' # you could add temp() around this to extract on the fly and not store it
    shell:
        'unzip -d {wildcards.app} {input.zip} {wildcards.file}'

        
rule vis_hippunfold:
    """ create command for visualizing data """
    input: 
        seg = 'hippunfold/work/sub-{subject}/anat/sub-{subject}_hemi-{hemi}_space-corobl_desc-subfields_atlas-bigbrain_dseg.nii.gz',
        t1 = 'hippunfold/work/sub-{subject}/anat/sub-{subject}_hemi-{hemi}_space-corobl_desc-preproc_T1w.nii.gz',
    output:
        vis_cmd = 'results/sub-{subject}_hemi-{hemi}_desc-subfields_vis.sh'
    shell:
        'echo "itksnap -g {input.t1} -s {input.seg}" > {output.vis_cmd} && '
        'chmod a+x {output}'

 
rule vis_hippunfold_tissue:
    """ create command for visualizing data """
    input: 
        seg = 'hippunfold/work/sub-{subject}/anat/sub-{subject}_hemi-{hemi}_space-corobl_desc-postproc_dseg.nii.gz',
        t1 = 'hippunfold/work/sub-{subject}/anat/sub-{subject}_hemi-{hemi}_space-corobl_desc-preproc_T1w.nii.gz',
    output:
        vis_cmd = 'results/sub-{subject}_hemi-{hemi}_desc-tissue_vis.sh'
    shell:
        'echo "itksnap -g {input.t1} -s {input.seg}" > {output.vis_cmd} && '
        'chmod a+x {output}'


rule vis_manual:
    input: 
        seg = config['manual_seg'],
        t1 = 'hippunfold/work/sub-{subject}/anat/sub-{subject}_hemi-{hemi}_space-corobl_desc-preproc_T1w.nii.gz',
    output:
        vis_cmd = 'results/sub-{subject}_hemi-{hemi}_rater-{rater}_vis.sh'
    shell:
        'echo "itksnap -g {input.t1} -s {input.seg}" > {output.vis_cmd} && '
        'chmod a+x {output}'


