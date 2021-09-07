include { testprofile } from './process/get_test_data/testprofile'


workflow get_test_data_wf {
    main: testprofile()
    emit: testprofile.out.flatten().map { file -> tuple(file.simpleName, file) }
}