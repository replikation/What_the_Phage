include { testprofile } from './get_test_data/testprofile'


workflow get_test_data_wf {
    main: testprofile()
    emit:
        fasta = testprofile.out.flatten().map { file -> tuple(file.simpleName, file) }
        test_files = testprofile.out.flatten()
}