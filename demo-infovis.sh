#!/bin/bash

DEMO_PATH=demo-infovis
DEMO_APP=infovis
DOWNLOAD_PATH=$DEMO_PATH/download
CORPUS_PATH=$DEMO_PATH/corpus
MODEL_PATH=$DEMO_PATH/model

function __create_folder__ {
	FOLDER=$1
	TAB=$2
	if [ ! -d $FOLDER ]
	then
		echo "${TAB}Creating folder: $FOLDER"
		mkdir $FOLDER
	fi
}

function __fetch_data__ {
	echo "# Setting up the infovis dataset..."
	__create_folder__ $DEMO_PATH "    "
	
	if [ ! -e "$DEMO_PATH/README" ]
	then
		echo "After a model is imported into a Termite server, you can technically delete all content in this folder without affecting the server. However you may wish to retain your model for other analysis purposes." > $DEMO_PATH/README
	fi

	if [ ! -d "$DOWNLOAD_PATH" ]
	then
		__create_folder__ $DOWNLOAD_PATH "    "
		echo "    Downloading the infovis dataset..."
		curl --insecure --location http://homes.cs.washington.edu/~jcchuang/misc/files/infovis-papers.zip > $DOWNLOAD_PATH/infovis-papers.zip
	else
		echo "    Already downloaded: $DOWNLOAD_PATH"
	fi
	
	if [ ! -d "$CORPUS_PATH" ]
	then
		__create_folder__ $CORPUS_PATH "    "
		echo "    Uncompressing the infovis dataset..."
		unzip $DOWNLOAD_PATH/infovis-papers.zip -d $CORPUS_PATH &&\
		    mv $CORPUS_PATH/infovis-papers/* $CORPUS_PATH &&\
		    rmdir $CORPUS_PATH/infovis-papers
	else
		echo "    Already available: $CORPUS_PATH"
	fi

	echo
}

function __train_model__ {
	echo "# Training an LDA model..."
	echo
	echo "bin/train_mallet_from_file.sh $CORPUS_PATH/infovis-papers.txt $MODEL_PATH"
	echo
	bin/train_mallet_from_file.sh $CORPUS_PATH/infovis-papers.txt $MODEL_PATH
}

function __import_model__ {
	echo "# Importing an LDA model..."
	echo
	echo "bin/ImportMallet.py $MODEL_PATH $DEMO_APP"
	echo
	bin/ImportMallet.py $MODEL_PATH $DEMO_APP
	echo
	echo "bin/ImportCorpus.py $DEMO_APP $CORPUS_PATH/infovis-papers-meta.txt"
	echo
	bin/ImportCorpus.py $DEMO_APP $CORPUS_PATH/infovis-papers-meta.txt
	echo
	mkdir apps/$DEMO_APP/data/stm
}

bin/setup.sh
__fetch_data__
__train_model__
__import_model__
bin/start_server.sh
