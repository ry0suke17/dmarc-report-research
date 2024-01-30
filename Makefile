AWS_S3_BUCKET=your-aws-s3-bucket

dep/install:
	brew install ripmime
	#
	# installed dependencies following cmd
	#
	# rm -rf third_party
	# mkdir third_party
	# git clone https://github.com/tierpod/dmarc-report-converter.git -b v0.6.5 third_party/dmarc-report-converter
	# cd ./third_party/dmarc-report-converter && make bin/dmarc-report-converter

# If you want to get it by date range, please check following.
# ref. https://stackoverflow.com/questions/69318367/amazon-s3-copy-files-after-date-and-with-regex
aws/report/download:
	aws s3 cp ${AWS_S3_BUCKET} ./report --recursive

report/rm:
	rm -rf report_attached_file
	rm -rf report_attached_file_unzip
	rm -rf report_attached_file_converted

report/mkdir:
	mkdir report_attached_file
	mkdir report_attached_file_unzip
	mkdir report_attached_file_converted

report/extract:
	ripmime -i report -d ./report_attached_file
	rm ./report_attached_file/textfile*

report/unzip:
	cp ./report_attached_file/* ./report_attached_file_unzip/
	cd ./report_attached_file_unzip
	find ./report_attached_file_unzip -name "*.gz" | xargs -n1 gzip -d 
	find ./report_attached_file_unzip -name "*.zip" | xargs -n1 unzip -d ./report_attached_file_unzip
	rm ./report_attached_file_unzip/*.zip

report/convert:
	./third_party/dmarc-report-converter/bin/dmarc-report-converter -config dmarc-report-converter-config.yaml

report/research: aws/report/download \
	report/rm \
	report/mkdir \
	report/extract \
	report/unzip \
	report/convert

