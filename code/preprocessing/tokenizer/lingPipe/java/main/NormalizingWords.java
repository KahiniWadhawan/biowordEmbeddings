//pending - writer to file logic, then test it,
// then move this file to main code - lua code lag dir
// take required jars as well - think abt code organization then

import com.aliasi.tokenizer.*;
import com.aliasi.util.Files;
import com.aliasi.util.Strings;

import java.io.*;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

//import java.nio.file.Files;


class NormalizingWords {

    final public static String data_DIR = "../../../../../../../data/";
    final public static String inputFiles = new File(data_DIR, "pubmedData/articles.txt.0-9A-B/").toString();
    final public static String tokenizedFiles_dir = new File(data_DIR, "TokenizedFiles/").toString();
    public static Boolean textwinfileTokensRequired = true;
    public static Boolean vocabTokensRequired = true;
    public static Boolean stemTokensRequired = false;
    public static Boolean punctuationsRemove = true;
    public static Boolean removeStopwords = true;

    public static ArrayList<String> tokenize(String line) {
        // create a new instance
        TokenizerFactory f1 = IndoEuropeanTokenizerFactory.INSTANCE;

        // create new object for lowercase tokenizing
        TokenizerFactory fLowercase = new LowerCaseTokenizerFactory(f1);

        //remove punctuations - revisit
//		if (punctuationsRemove == true){
//			//Pattern punctPattern = Pattern.compile("[^\\p{Punct}]");
//			Pattern punctPattern = Pattern.compile("[\\p{L}\\p{Nd}]"); //alphanumeric
//			TokenizerFactory fRemovePunct = new RegExFilteredTokenizerFactory(f1,punctPattern);
//			fLowercase = new LowerCaseTokenizerFactory(fRemovePunct);
//		}

        //runs if removeStopwords is not true
        Tokenization tk = new Tokenization(line, fLowercase);

        // create new object for english stop word list
        if (removeStopwords == true) {
            TokenizerFactory fStopEngTokenize = new EnglishStopTokenizerFactory(fLowercase);
            // do tokenizing for line based on the english stop word list that we
            // have created - overwrite the previous tk
            tk = new Tokenization(line, fStopEngTokenize);
        }

        // get whole tokens result
        String[] result = tk.tokens();
        // store to arraylist, it is optional, you could resurn String[] also.
        ArrayList<String> arrResultToken = new ArrayList<String>();
        for (int i = 0; i < result.length; i++) {
            //removing punct here - revisit
            //if(removeStopwords == true && Strings.allPunctuation(result[i]) == false) {
            //if(Pattern.matches("'\'p{Punct}", result[i])) {
            if (punctuationsRemove == true && Strings.allPunctuation(result[i]) == true) {
                //System.out.println("entered in Strings all Punctuation" + result[i]);
                //arrResultToken.add(result[i]);
                continue;
            } else {
                //System.out.println("entered else punct " + result[i]);
                arrResultToken.add(result[i]);
            }
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


    public static void writeOutput(String fn, ArrayList<String> arrTokens, int isVocabTokens) {
        //creating same folder structure for tokenizedFiles as in inputFiles
        // String tokenizedFiles_dir = "../../../../../../data/TokenizedFiles/";
        String filepath = "";
        String foldername = "";
        if (isVocabTokens == 1) {
            foldername = tokenizedFiles_dir + "/VocabTokenFiles";
            filepath = foldername + "/Vocabtokens_" + fn;
        } else {
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
        } catch (IOException ex) {
            System.out.println("Error writing to file '" + filepath + "'");
            // ex.printStackTrace();
        }
    }

    public static void processText(File file) throws IOException {
        // Remove stop word list and tokenize them into tokens.
        //If use stemming here - then use in textwinfile block as well
        String text = "";
        try {
            text = Files.readFromFile(file, "ISO-8859-1");
        } catch (IOException ex) {
            System.out.println("Error extracting text from file" + file.getPath());
        }
        ArrayList<String> arrTokens = new ArrayList<String>();
        String currentFilename = file.getName();
        //Boolean removeStopwords = false;

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

            //removeStopwords = false;
            //Preparing tokenized text_file for text_win_file
            //Not removing stop words, using IndoEuropean, lowercase and Punctuation(to be added)
            arrTokens = tokenize(text);   //revisit - pass line or full text - optimize
            // Stemming the tokens
            if (stemTokensRequired == true) {
                arrTokens = stemming(arrTokens);
            }

            writeOutput(currentFilename, arrTokens, 0);
        }
    }


    public static void main(String[] args) throws IOException {
        long startTime = System.currentTimeMillis();
        //Collection reader for a dir of text files
        System.out.println("inputFiles :: " + inputFiles);
        //Files.walk(Paths.get(inputFiles)).forEach(filePath -> {
        try {
            java.nio.file.Files.walk(new File(inputFiles).toPath()).forEach(filePath -> {

                if (java.nio.file.Files.isRegularFile(filePath)) {
                    //System.out.println("filePath type ::" + filePath.toString());
                    File file = new File(filePath.toString());
                    //calling tokenizer and file writer function
                    try {
                        processText(file);
                    } catch (IOException ex) {
                        System.out.println("Error reading files in main function");
                    }
                }
            });
        } catch (IOException ex) {
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

        long endTime = System.currentTimeMillis();
        long totalTime = endTime - startTime;
        System.out.println("total processing time:: " + totalTime / (1000));
    }
}
