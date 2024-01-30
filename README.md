# dmarc-report-research

Download dmarc report from AWS S3 and generate files for research.

## Usage

Install dependencies with the following.

```
make dep/install
```

Generate files for research DMARC report.

```
make report/research AWS_S3_BUCKET=your-aws-s3-bucket
```

Execute the following script if you attach info about the domain owner, etc.

```
 ./script/dmarc-report-detail.sh ./report_attached_file_unzip/your-dmarc-report-xml
```
