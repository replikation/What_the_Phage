process summary {
        label 'rmarkdown'  
        publishDir "${params.output}/", mode: 'copy', pattern: "final_report.html"
    input:
        path(files)
        path(markdown)
        path(logo)
    output:
        path("final_report.html")
    script:
        """
        # move relevant files into dedicated dir
            mkdir -p render_dir
            cp ${markdown} render_dir/final_report.Rmd
            cp *.input render_dir/
            cp *.svg render_dir/ 2>/dev/null || :
            cp logo-wtp_small.png render_dir/logo.png
        # append sample Rmds to final report
            for FILE in *_report*.Rmd; do
                printf "\\n" >> render_dir/final_report.Rmd
                cat  \${FILE} >> render_dir/final_report.Rmd
                printf "\\n" >> render_dir/final_report.Rmd
            done
        # render
            Rscript -e "rmarkdown::render('render_dir/final_report.Rmd')"
        cp render_dir/final_report.html final_report.html
        """
    stub:
        """
        # move relevant files into dedicated dir
            mkdir -p render_dir
            cp ${markdown} render_dir/final_report.Rmd
            cp *.input render_dir/
            cp *.svg render_dir/ 2>/dev/null || :
        # append sample Rmds to final report
            for FILE in *_sample_report.Rmd; do
                printf "\\n" >> render_dir/final_report.Rmd
                cat  \${FILE} >> render_dir/final_report.Rmd
                printf "\\n" >> render_dir/final_report.Rmd
            done
        cp render_dir/final_report.Rmd final_report.html
        """
}