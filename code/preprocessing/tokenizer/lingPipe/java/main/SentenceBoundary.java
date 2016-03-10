 //alternative way to read files - can go in main()
           /*File folder = new File(inputFiles);
          File[] listOfFiles = folder.listFiles();

          for (File file : listOfFiles) {
          	if (file.isFile()) {
        		System.out.println(file.getName());
			String text = Files.readFromFile(file,"ISO-8859-1");
   			//calling tokenizer and file writer function
 			processText(text);

     		}
	  }*/

	  //Sentence detection - include it in processText() above, if needed
	  /*List<String> tokenList = new ArrayList<String>();
	  List<String> whiteList = new ArrayList<String>();
	  Tokenizer tokenizer = TOKENIZER_FACTORY.tokenizer(text.toCharArray(),0,text.length());
	  tokenizer.tokenize(tokenList,whiteList);

	  System.out.println(tokenList.size() + " TOKENS");
	  System.out.println(whiteList.size() + " WHITESPACES");

          String[] tokens = new String[tokenList.size()];
	  String[] whites = new String[whiteList.size()];
	  tokenList.toArray(tokens);
	  whiteList.toArray(whites);

          int[] sentenceBoundaries = SENTENCE_MODEL.boundaryIndices(tokens,whites);

	  System.out.println(sentenceBoundaries.length
			   + " SENTENCE END TOKEN OFFSETS");

	  if (sentenceBoundaries.length < 1) {
	  	System.out.println("No sentence boundaries found.");
	    	return;
	  }
	  int sentStartTok = 0;
	  int sentEndTok = 0;
	  for (int i = 0; i < sentenceBoundaries.length; ++i) {
	  	sentEndTok = sentenceBoundaries[i];
	    	System.out.println("SENTENCE "+(i+1)+": ");
	    	for (int j=sentStartTok; j<=sentEndTok; j++) {
			System.out.print(tokens[j]+whites[j+1]);
	    	}
	    	System.out.println();
	    	sentStartTok = sentEndTok+1;
	  }
	  //Kahini modification
	  for(int i=0; i<tokens.length; i++){
	  	System.out.println("PRINTING TOKENS ....");
		System.out.println(tokens[i]);
	  }
          //Kahini modification
	  */ //Sentence detection block

