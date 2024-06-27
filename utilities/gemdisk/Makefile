build:
	env GOOS=darwin GOARCH=amd64  go build -o /usr/local/bin/gemdisk .


	env GOOS=darwin GOARCH=amd64  go build -o ./bin/macos-amd64/gemdisk .
	env GOOS=darwin GOARCH=arm64  go build -o ./bin/macos-arm64/gemdisk .
	env GOOS=windows GOARCH=386  go build -o ./bin/windows-386/gemdisk.exe .
	env GOOS=windows GOARCH=amd64  go build -o ./bin/windows-amd64/gemdisk.exe .
	env GOOS=linux GOARCH=amd64  go build -o ./bin/linux-amd64/gemdisk .
	env GOOS=linux GOARCH=arm64  go build -o ./bin/linux-arm64/gemdisk .
	env GOOS=linux GOARCH=arm  go build -o ./bin/linux-arm/gemdisk .

	#zip -v ./telstar-upload-2.0/telstar-upload-2.0.zip ./telstar-upload-2.0/telstar-upload-macos-amd64 ./telstar-upload-2.0/telstar-upload-macos-arm64 ./telstar-upload-2.0/telstar-upload-windows-386.exe ./telstar-upload-2.0/telstar-upload-windows-amd64.exe ./telstar-upload-2.0/telstar-upload-linux-amd64 ./telstar-upload-2.0/telstar-upload-linux-arm64

	# update the deployment folder with the amd64 version
	#cp ./telstar-upload-2.0/telstar-upload-linux-amd64 ../../telstar-2-system/telstar-deployment/opt/telstar/telstar-upload
