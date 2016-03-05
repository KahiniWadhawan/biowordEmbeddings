//pending - writer to file logic, then test it, 
// then move this file to main code - lua code lag dir 
// take required jars as well - think abt code organization then  

import com.aliasi.sentences.MedlineSentenceModel;
import com.aliasi.sentences.SentenceModel;

import com.aliasi.tokenizer.PorterStemmerTokenizerFactory;
import com.aliasi.tokenizer.IndoEuropeanTokenizerFactory;
import com.aliasi.tokenizer.EnglishStopTokenizerFactory;
import com.aliasi.tokenizer.RegExFilteredTokenizerFactory;
import com.aliasi.tokenizer.LowerCaseTokenizerFactory;
import com.aliasi.tokenizer.StopTokenizerFactory;
import com.aliasi.tokenizer.TokenizerFactory;
import com.aliasi.tokenizer.Tokenization;
import com.aliasi.tokenizer.Tokenizer;
import com.aliasi.util.CollectionUtils;

import com.aliasi.util.Strings;
import com.aliasi.util.Files;

import java.io.File;
import java.io.IOException;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Arrays;
import java.util.List;
import java.util.Set;


import java.nio.file.Paths;
//import java.nio.file.Files; 
import java.io.*;
import java.util.regex.Pattern;


class NormalizingWords {

     public static Boolean textwinfileTokensRequired = true; 
     public static Boolean vocabTokensRequired = true; 
     public static Boolean stemTokensRequired = false;
     public static Boolean punctuationsRequired = true;  

     //final static String inputFiles = System.getProperty("user.dir");
     //System.out.println("current dir = " + inputFiles);
     final public static String inputFiles ="../../../../../../data/pubmedData/articles.txt.0-9A-B/" ;   //revisit - think abt getting relative path  

     
     public static ArrayList<String> tokenize(String line, Boolean removeStopwords) {
          // create a new instance
          TokenizerFactory f1 = IndoEuropeanTokenizerFactory.INSTANCE;
          
          //remove punctuations - revisit 
	  //if (punctuationsRequired == true){
	  //Pattern punctPattern = Pattern.compile("[^\\p{Punct}]");
	  //TokenizerFactory fRemovePunct = new RegExFilteredTokenizerFactory(f1,punctPattern);
          //}

          // create new object for lowercase tokenizing
          TokenizerFactory fLowercase = new LowerCaseTokenizerFactory(f1);
          //TokenizerFactory fLowercase = new LowerCaseTokenizerFactory(fRemovePunct);
          
	  //remove punctuations - revisit 
	  //if (punctuationsRequired == true){
	  //Pattern punctPattern = Pattern.compile("[^\\p{Punct}]");
          //Pattern punctPattern = Pattern.compile("[^,]");
	  //TokenizerFactory fRemovePunct = new RegExFilteredTokenizerFactory(fLowercase,punctPattern);
          //}

 
          //runs if removeStopwords is not true
	  Tokenization tk = new Tokenization(line, fLowercase);
	  
	  /*String[] temp1 = tk1.tokens();
	  for (int i = 0; i < temp1.length; i++) {
	  	System.out.println("tokens1 w/o punctRemove :: " + temp1[i]);
	  } 
          
          Tokenization tk = new Tokenization(line, fRemovePunct);
          String[] temp = tk.tokens();
	  for (int i = 0; i < temp.length; i++) {
	  	System.out.println("tokens w punctRemove:: " + temp[i]);
	  } */

          // create new object for english stop word list
	  if(removeStopwords == true){
          	TokenizerFactory fStopEngTokenize = new EnglishStopTokenizerFactory(fLowercase);
		//TokenizerFactory fStopEngTokenize = new EnglishStopTokenizerFactory(fRemovePunct);

	        // do tokenizing for line based on the english stop word list that we
        	// have created - overwrite the previous tk 
	        tk = new Tokenization(line, fStopEngTokenize);
	  }
	  /*else {
		Tokenization tk = new Tokenization(line, fLowercase);
	  } */
          // get whole tokens result
          String[] result = tk.tokens();
          // store to arraylist, it is optional, you could resurn String[] also.
          ArrayList<String> arrResultToken = new ArrayList<String>();
          for (int i = 0; i < result.length; i++) {
	      	//removing punct here - revisit 
	  	if(removeStopwords == true && Strings.allPunctuation(result[i]) == false)
                	arrResultToken.add(result[i]);
                else 
			arrResultToken.add(result[i]);
          }
          return arrResultToken;
     }

     public static ArrayList<String> stemming(ArrayList<String> token) {
          TokenizerFactory f1 = IndoEuropeanTokenizerFactory.INSTANCE;
          TokenizerFactory fPorter = new PorterStemmerTokenizerFactory(f1);
          ArrayList<String> arrResultStem = new ArrayList<String>();
          for (int i = 0; i < token.size(); i++) {
              Tokenization tk1 = new Tokenization(token.get(i), fPorter);
              String[] rs = tk1.tokens();
              arrResultStem.add(rs[0]);
          }
          return arrResultStem;
     }


     public static void writeOutput(String fn, ArrayList<String> arrTokens, int isVocabTokens){
	 //creating same folder structure for tokenizedFiles as in inputFiles
	 String tokenizedFiles_dir = "../../../../../../data/TokenizedFiles/"; 
         String filepath = ""; 
	 String foldername = ""; 
	 if(isVocabTokens == 1){
                foldername = tokenizedFiles_dir + "/VocabTokenFiles";
         	filepath = foldername + "/Vocabtokens_" + fn;  
	 }
	 else{  
		foldername = tokenizedFiles_dir + "/TextWinTokenFiles";
     		filepath = foldername + "/TextWintokens_" + fn;  
         }
	 
	 //System.out.println("Writing file :: " + filepath);
         //create if folder does not exist, otherwise just change the folder - revisit 
	 try {
            FileWriter fileWriter = new FileWriter(filepath);
            BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);
	    for (String string3 : arrTokens) {

            	bufferedWriter.write(string3);
	        bufferedWriter.write(" ");
        	//bufferedWriter.newLine();
            }
            bufferedWriter.close();
        }
        catch(IOException ex) {
            System.out.println("Error writing to file '"+ filepath + "'");
            // ex.printStackTrace();
        }
     }

 
     //public void processText(String text, Object filepath, File inputfile) {
     //public static void processText(String text, File inputfile) {
     public static void processText(File file) throws IOException {
          // Remove stop word list and tokenize them into tokens.
	  //If use stemming here - then use in textwinfile block as well
	  String text = ""; 
	  
	  try{
          	text = Files.readFromFile(file,"ISO-8859-1"); 
	  }catch(IOException ex){
		System.out.println("Error extracting text from file" + file.getPath());
	  }
	  ArrayList<String> arrTokens = new ArrayList<String>();
          String currentFilename = file.getName();
	  Boolean removeStopwords = false;

	  /*if (vocabTokensRequired == true) {
		removeStopwords = true;
          	arrTokens = tokenize(text, removeStopwords);   //revisit - pass line or full text - optimize
          	// Stemming the tokens
                if (stemTokensRequired == true) { 
          		arrTokens = stemming(arrTokens);
	        }

	     	writeOutput(currentFilename,arrTokens,1);			
          }*/

	  if (textwinfileTokensRequired == true) {
        
                removeStopwords = false;
	 	//Preparing tokenized text_file for text_win_file 
	 	//Not removing stop words, using IndoEuropean, lowercase and Punctuation(to be added)
	  	arrTokens = tokenize(text, removeStopwords);   //revisit - pass line or full text - optimize
          	// Stemming the tokens
		if (stemTokensRequired == true) { 
		  	arrTokens = stemming(arrTokens);
          	}
		
		writeOutput(currentFilename,arrTokens,0);
	  }
  } 


     public static void main(String[] args) throws IOException {   
          long startTime = System.currentTimeMillis();  	  
	  //Collection reader for a dir of text files 
	  System.out.println("inputFiles :: " + inputFiles); 
          //Files.walk(Paths.get(inputFiles)).forEach(filePath -> {
	  try{
	  java.nio.file.Files.walk(new File(inputFiles).toPath()).forEach(filePath -> {
        
       		if (java.nio.file.Files.isRegularFile(filePath)) {
	        	//System.out.println("filePath type ::" + filePath.toString());
			File file = new File(filePath.toString()); 
   			//calling tokenizer and file writer function
 			//processText(text, filePath, file);
			//processText(text,file);
			try{
			processText(file);
			}catch(IOException ex){
				System.out.println("Error reading files in main function");
			}
    		}
       	  });
         }catch(IOException ex){
 	 	System.out.println("Error reading files in main function");
	}//catch ends here 

          
	  /*File folder = new File(inputFiles);
          File[] listOfFiles = folder.listFiles();

          for (File file : listOfFiles) {
          	if (file.isFile()) {
        		System.out.println(file.getName());
			String text = Files.readFromFile(file,"ISO-8859-1"); 
   			//calling tokenizer and file writer function
 			processText(text,file);
			
     		}
	  }//for loop ends here  */

	long endTime   = System.currentTimeMillis();
	long totalTime = endTime - startTime;
	System.out.println("total processing time:: " + totalTime/(1000));    
    } 
}






          
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


