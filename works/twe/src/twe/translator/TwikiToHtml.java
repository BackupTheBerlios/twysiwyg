/**
 * <p>Titre : Twiki translator</p>
 * <p>Description : Projet permettant de traduire la syntaxe twiki en html et html en twiki</p>
 * <p>Copyright : Copyright (c) 2003 Fr�d�ric Luddeni</p>
 * <p>Soci�t� : IutForce</p>
 * @author Fr�d�ric Luddeni (frederic.luddeni@wanadoo.fr)
 * @version 1.06
 * <PRE>
 * - Todo :
 *   * Prendre en charge les lignes trac�es apr�s du texte (creer un tableau contenant hr).
 * version 1.07:
 * -------------
 *  - Modifs:
 *     * Modif de nopsProcess en ajoutant la traduction de <nop/>, <nop /> et <nop >.
 *
 * Version 1.06:
 * ----------
 * - Modifs:
 *    * Modification des m�thodes propres aux tableaux avec un bug li� au colspan. Le colspan
 *      se mettait toujours sur le dernier td.
 *
 * Version 1.05:
 * ----------
 * - Modifs:
 *    * Modification des expressions r�guli�res dans "stylesProcess" (bugs enfin fix�s).
 *    * Modification des liens en ajoutant un attribut 'class' pour les wikiWords.
 *
 * Version 1.04:
 * ----------
 * - Modifs:
 *    * Modification des expressions r�guli�res dans "stylesProcess".
 *    * Modification de la m�thode translateStyle pour prendre en compte les nouvelles expressions r�guli�res.
 *
 *
 * Version 1.03:
 * ----------
 * - Modifs:
 *    * Ajouter une m�thode translate qui retourne un arbre DOM, g�n�r� par tidy.
 *
 * Version 1.02:
 * -------------
 * - Modifs:
 *    * Remplacement de tous les <P/> par <P>.
 *    * Remplacement de tous les <HR/> par <HR>.
 *    * Remplacement des <A .../> par <A ...></A>.
 *
 * Version 1.01:
 * ----------
 * - Ajouts:
 *   * private static ArrayList translate(ArrayList text).
 *   * public static String translate(FileInputStream fis).
 *   * private static ArrayList getTextArray(FileInputStream fis)
 *
 * - Modifs:
 *   * translate(ArrayList text) en translate(String sText).
 *
 * Probl�me :
 * - Verifier expressions r�guli�res : Probl�me avec le gras. cf. exemple avec le tableau.
 *
 *
 * Version 1:
 * ----------
 * Processed :
 * - Headings '---+', '---++', '---+++', '---++++', '---+++++' et '---++++++'.
 * - Bold Text '*boldText*'.
 * - Italic Text '_italicText_'.
 * - Bold Italic Text __boldItalicText__'.
 * - Fixed Font '=fixedFont='.
 * - Bold Fixed Font '==boldFixedFont=='.
 * - Paragraphs 'Blanck line'.
 * - Verbatim Mode '\n<VERBATIM>\n</VERBATIM>\n'.
 * - Separator '---'.
 * - Prevent a Link '<nop>.
 * - List Item.
 * - Nested List Item.
 * - Ordered List.
 * - Definition List. (DL => DT => DD)
 * - Forced Links, WikiWord Links, Anchors, Specific Links.
 * - Table.
 * </PRE>
 */
package twe.translator;

import java.io.*;
import java.util.*;
import java.util.regex.*;
import org.w3c.dom.*;
import org.w3c.tidy.*;
import java.io.StringWriter;

public class TwikiToHtml {
  private TwikiToHtml() {

  }

  /**
   * Permet de traduire la chaine sText, se trouvant sous la syntaxe twiki, en syntaxe Html.
   * @param sText La chaine � traduire.
   * @param errout Flux o� sera affich� les erreurs de syntaxe html. Si � null, alors par d�faut,
   * @param showWarnings Permet de sp�cifier si on veut que les warnings soient affich�s ou pas dans
   * errout.
   * @return Un objet de type document contenant la traduction de sText en syntaxe twiki.
   * @throws IOException Lev�e si une erreur se produit.
   */
  public static Document translate(String sText, PrintWriter errout, boolean showWarnings) throws IOException {
    return getDocument(TwikiToHtml.translate(sText), errout, showWarnings);
  }


  /**
   * Permet de traduire le flux  fis, se trouvant sous la syntaxe twiki, en syntaxe Html.
   * @param fis Le flux � traduire.
   * @param errout Flux o� sera affich� les erreurs de syntaxe html. Si � null, alors par d�faut,
   * @param showWarnings Permet de sp�cifier si on veut que les warnings soient affich�s ou pas dans
   * errout.
   * @return Un objet de type document contenant la traduction de fis en syntaxe twiki.
   * @throws IOException Lev�e si une erreur se produit.
   */
  public static Document translate(FileInputStream fis, PrintWriter errout, boolean showWarnings) throws IOException {
    String sText = TwikiToHtml.translate(fis);
    return getDocument(sText, errout, showWarnings);
  }

  /**
   * Permet de retourner un objet de type Document construit autour de sText.
   * @param sText Le texte original.
   * @param errout Flux o� sera affich� les erreurs de syntaxe html. Si � null, alors par d�faut,
   * @param showWarnings Permet de sp�cifier si on veut que les warnings soient affich�s ou pas dans
   * errout.
   * @return Un objet de type Document.
   * @throws IOException Lev�e si une erreur se produit.
   */
  private static Document getDocument(String sText, PrintWriter errout, boolean showWarnings) throws IOException{
    File temp = File.createTempFile("TwikiToHtml", ".tmp");
    temp.deleteOnExit();
    PrintWriter msg = new PrintWriter(new FileWriter(temp));
    msg.print(sText);
    msg.close();
    // new StringReader(sText);
    Tidy tidy = new Tidy();
    tidy.setShowWarnings(showWarnings);
    tidy.setMakeClean(true);
    tidy.setXHTML(true);
    if (errout != null) {
      tidy.setErrout(errout);
    }

    return tidy.parseDOM(new FileInputStream(temp), null);
  }

  /**
   * Permet de traduire le flux  fis, se trouvant sous la syntaxe twiki, en syntaxe Html.
   * @param fis Le flux � traduire.
   * @return La cha�ne contenant la traduite.
   */
  public static String translate(FileInputStream fis) {
    ArrayList array = translate(getTextArray(fis));
    String sText = "";
    for (int i = 0; i < array.size(); ++i) {
      sText += array.get(i) + "\n";
    }
    return sText;
  }

  /**
       * Retourne un ArrayList contenant toutes les donn�es du flux pass� en param�tre.
   * @param fis Le flux dont on veut r�cup�rer le contenu.
   * @return Un ArrayList contenant le contenu de fis.
   */
  private static ArrayList getTextArray(FileInputStream fis) {
    LineNumberReader lnr = null;
    ArrayList newArray = new ArrayList();
    String sText = "";
    try {
      lnr = new LineNumberReader(new InputStreamReader(fis));

      while (lnr.ready()) {
        newArray.add(lnr.readLine());
      }
    }
    catch (FileNotFoundException ex) {
      System.out.println("FileNotFoundException : " + ex.getMessage());
    }
    catch (IOException ex) {
      System.out.println("IOException : " + ex.getMessage());
    }
    finally {
      if (lnr != null)
        try {
          lnr.close();
        }
        catch (IOException ex) {
          System.out.println("IOException : " + ex.getMessage());
        }
    }
    return newArray;
  }

  /**
   * Permet de traduire la chaine sText, se trouvant sous la syntaxe twiki, en syntaxe Html.
   * @param sText La cha�ne � traduire.
   * @return La cha�ne traduite.
   */
  public static String translate(String sText) {
    String[] sTextBis = sText.split("\n");
    ArrayList text = new ArrayList();
    for (int i = 0; i < sTextBis.length; ++i) {
      text.add(sTextBis[i]);
    }
    text = translate(text);

    sText = "";
    for (int i = 0; i < text.size(); ++i) {
      sText += text.get(i) + "\n";
    }
    return sText;
  }

  /**
   * M�thode permettant de traiter le contenu de 'text' pour transcrire
   * la syntaxe twiki en html.
   * <BR>
   * Sont support�s pour l'instant :
   * <UL>
   * <LI>- Le traitement des titres.</li>
   * <LI>- Le traitement des tableaux.</li>
   * <LI>- Le traitement des styles (gras, italique, gras-italique).</li>
   * <LI>- Le traitement des paragraphes.</li>
   * <LI>- Le traitement verbatim.</li>
   * <LI>- Le traitement des s�parateurs.</li>
   * <LI>- Le traitement des listes.</li>
   * <LI>- Le traitement des listes num�rot�es.</li>
   * <LI>- Le traitement des listes de d�finitions.</li>
   * <LI>- Le traitement des liens.</li>
   * <LI>- Le traitement des nop.</li>
   * </UL>
   * @param text Le ArrayList contenant les lignes respectant la syntaxe twiki.
   * @return Un ArrayList ayant le contenu de 'text' traduit au format html.
   */
  private static ArrayList translate(ArrayList text) {
    // Traitment des titres.
    text = titlesProcess(text);
    text = tablesProcess(text);
    // Traitement du style (gras, italique,gras-italique).
    text = stylesProcess(text);
    // Traitement les paragraphes.
    text = ParagraphsProcess(text);
    text = verbatimsProcess(text);
    text = separatorsProcess(text);
    text = listsProcess(text);
    text = orderListsProcess(text);
    text = definitionListsProcess(text);
    text = linksProcess(text);
    text = nopsProcess(text);

    return text;
  }

  /**
   * Permet de traiter toutes les lignes du texte en rempla�ant les balises
   * des titres respectant la syntaxe twiki sous la syntaxe HTML.
   * @param text L'arrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList titlesProcess(ArrayList text) {
    text = linesProcess(text, "^(---\\+)(?=[^\\+])", "---+", "<H1>", "</H1>");
    text = linesProcess(text, "^(---\\+\\+)(?=[^\\+])", "---++", "<H2>", "</H2>");
    text = linesProcess(text, "^(---\\+\\+\\+)(?=[^\\+])", "---+++", "<H3>", "</H3>");
    text = linesProcess(text, "^(---\\+\\+\\+\\+)(?=[^\\+])", "---++++", "<H4>",
                        "</H4>");
    text = linesProcess(text, "^(---\\+\\+\\+\\+\\+)(?=[^\\+])", "---+++++", "<H5>",
                        "</H5>");
    text = linesProcess(text, "^(---\\+\\+\\+\\+\\+\\+)(?=[^\\+])", "---++++++",
                        "<H6>", "</H6>");
    return text;
  }

  /**
   * Retourne un ArrayList avec toutes les modifs. Permet de traiter toutes
   * les balises ouvrante et fermante sur une ligne.
   * @param text ArrayList contenant le texte � traiter.
   * @param regex La cha�ne � rechercher.
   * @param sBalisetwiki La balise � remplacer.
   * @param sBaliseOuvrante La balise qui remplace sChaineTwikiARemplacer.
   * @param sBaliseFermante Si la balise est trouv� dans une ligne, celle ci est ajout� � la fin de la ligne.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList linesProcess(ArrayList text,
                                        String regex,
                                        String sBalisetwiki,
                                        String sBaliseOuvrante,
                                        String sBaliseFermante) { /** @todo Supprimer la balise sBalisetwiki si tests bon*/
    for (int i = 0; i < text.size(); ++i) {
      String sCurrentLine = (String) text.get(i);
      Matcher m = Pattern.compile(regex).matcher(sCurrentLine);
      if (m.find()) {
        sCurrentLine = sBaliseOuvrante+
            sCurrentLine.substring(m.end()).trim() +sBaliseFermante;
        text.set(i, sCurrentLine);
      }
    }
    return text;
  }

  /**
   * Permet de traduire les styles (gras, italique, gras-italique) de la
   * syntaxe twiki vers la syntaxe Html.
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList stylesProcess(ArrayList text) {
    // Traitement du Bold.
    /*text = translateStyle(text, "(((?=\\>?| |^)\\*(?=[^ ]))([^\\*]|( \\*))*(([^ ]\\*)(?=\\<?| |$))){1}","*", "<B>", "</B>");*/
    text = translateStyle(text, "(^|(?<=(\\>))|[\\s\\(])\\*([^\\s]+?|[^\\s].*?[^\\s])(\\*)($|(?=(\\<))|(?=([\\s\\,\\.\\;\\:\\!\\?\\)])))",
                          "*", " <B>", "</B> ");

    // Traitement de Bold Italic.
    /*text = translateStyle(text, "(((?=\\>?| |^)__(?=[^ ]))([^_]|(( _)|(__)))*(([^ ]__)(?=\\<?| |$))){1}", "__"," <B><I>", "</I></B> ");*/
    text = translateStyle(text, "(^|(?<=(\\>))|[\\s\\(])__([^_\\s]+?|[^_\\s].*?[^_\\s])__($|(?=(\\<))|(?=([\\s\\,\\.\\;\\:\\!\\?\\)])))",
                          "__", "<B><I>", "</I></B>");

    // Traitement de Italic.
    /*
         text = translateStyle(text, "(((?:\\>?| |^)_(?=[^ _]))([^_]|(( _)|(__)))*(([^ ]_)(?:\\<?| |$))){1}", "_"," <I>", "</I> ");*/
    text = translateStyle(text, "(^|(?<=(\\>))|[\\s\\(]){1}_([^_\\s]+?|[^_\\s].*?[^_\\s])_($|(?=(\\<))|(?=([\\s\\,\\.\\;\\:\\!\\?\\)])))",
                          "_",
                          "<I>", "</I>");

    // Traitement de Bold fixed font.
    /*text = translateStyle(text, "(((?=\\>?| |^)==(?=[^ ]))([^=]|(( =)|(==)))*(([^ ]==)(?=\\<?| |$))){1}", "=="," <B><CODE>", "</CODE></B> ");*/
    text = translateStyle(text, "(^|(?<=(\\>))|[\\s\\(])==([^=\\s]+?|[^=\\s].*?[^=\\s])==($|(?=(\\<))|(?=([\\s\\,\\.\\;\\:\\!\\?\\)])))",
                          "==", "<B><CODE>", "</CODE></B>");

    // Traitement de fixed font.
    /*text = translateStyle(text, "(((?=\\>?| |^)=(?=[^= \"\']))([^=]|(( =)|(==)))*(([^ ]=)(?=\\<?| |$))){1}", "="," <CODE>", "</CODE> ");*/
    text = translateStyle(text, "(^|(?<=(\\>))|[\\s\\(])=([^=\\s\"\']+?|[^=\\s\"\'].*?[^=\\s])=([^\"\']?)($|(?=(\\<))|(?=([\\s\\,\\.\\;\\:\\!\\?\\)])))",
                          "=",
                          "<CODE>", "</CODE>");
    return text;
  }

  /**
   * Permet de traiter les styles de la syntaxe twiki pour les transcrire
   * en syntaxe Html. Lorsque regex est d�tect� dans une ligne, la balise
   * twikiTag est remplac�e respectivement par les balises openningHtmlTag et
   * closingHtmlTag.
   * @param text ArrayList contenant le texte � traiter.
   * @param regex Expression r�guli�re repr�sentant la syntaxe twiki du style.
   * @param twikiTag balise du style sous la syntaxe twiki.
   * @param openningHtmlTag balise ouvrante du style sous la syntaxe html.
   * @param closingHtmlTag balise fermante du style sous la syntaxe html.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList translateStyle(ArrayList text, String regex,
                                          String twikiTag,
                                          String openningHtmlTag,
                                          String closingHtmlTag) {
    for (int i = 0; i < text.size(); ++i) {
      String sCurrentLineProcess = "";
      String sCurrentLine = (String) text.get(i);
      Pattern p = Pattern.compile(regex);
      Matcher m = p.matcher(sCurrentLine);
      boolean result = m.find();
      if (result == true) {
        int startChain = 0;
        while (result) {
          int startRegex = m.start();
          int endRegex = m.end();
          // recuperation du d�but de la chaine (avant regex).
          sCurrentLineProcess += sCurrentLine.substring(startChain,
              startRegex);
          // Recuperation de la chaine comprise entre twikiTag ouvrant & twikiTag fermant.
          String sRegex = sCurrentLine.substring(startRegex, endRegex);

          // Modifs
          /*
          sRegex = sRegex.substring(twikiTag.length());
          sRegex = sRegex.substring(0, sRegex.length() - twikiTag.length());*/
          sRegex = sRegex.substring(sRegex.indexOf(twikiTag)+twikiTag.length());
          sRegex = sRegex.substring(0, sRegex.lastIndexOf(twikiTag));

          // Construction de la chaine
          if (sRegex.length() > 0)
            sCurrentLineProcess += openningHtmlTag + sRegex + closingHtmlTag;

          startChain = endRegex;
          result = m.find();
          if (!result) {
            // Recuperation de la fin de la chaine.
            sCurrentLineProcess += sCurrentLine.substring(endRegex);
          }
        }
      }
      else {
        sCurrentLineProcess = sCurrentLine;
      }
      text.set(i, sCurrentLineProcess);
    }
    return text;
  }

  /**
   * Permet de traiter les tableaux.
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList tablesProcess(ArrayList text) {
    boolean isTable = false;
    Pattern p = Pattern.compile("^( )*(\\|([^\\|])+\\|)+");
    ArrayList listTable = new ArrayList();
    int maxColomns = 0, noStartTableLine = 0;
    for (int i = 0; i < text.size(); ++i) {
      //String sCurrentLineProcess = "";
      String sCurrentLine = (String) text.get(i);
      Matcher m = p.matcher(sCurrentLine);
      boolean result = m.find();
      if (result) {
        if (!isTable) {
          isTable = true;
          listTable.clear();
          noStartTableLine = i;
          maxColomns = 0;
        }
        Matcher mTd = Pattern.compile("(([^\\|])+([\\|])+)").matcher(sCurrentLine);
        ArrayList listTr = new ArrayList();
        while (mTd.find()) {
          String sTd = sCurrentLine.substring(mTd.start(),mTd.end());
          sTd = (sTd.startsWith("|"))?sTd.substring(1):sTd;
          sTd = (sTd.endsWith("|"))?sTd.substring(0,sTd.length()-1):sTd;
          listTr.add(tdProcess(sTd));
        }
        listTable.add(listTr);
        maxColomns = ( (listTr.size()) > maxColomns) ? listTr.size() :
            maxColomns;
      }
      else {
        // Cas ou il y a encore du texte apr�s le tableau.
        if (isTable) {
          tableProcess(text, listTable, maxColomns, noStartTableLine);
          isTable = false;
        }
        text.set(i, sCurrentLine);
      }
    }
    // Cas ou le tableau est en fin de fichier.
    if (isTable) {
      tableProcess(text, listTable, maxColomns, noStartTableLine);
    }
    return text;
  }

  /**
   * Permet de traiter les donn�es d'un tableau lorsqu'il a �t� extrait du texte original.
   * @param text Le texte original.
   * @param TableData La liste des donn�es du tableau � traiter.
   * @param maxColomns Le nombre maximum de colonnes du tableau.
       * @param noStartTableLine L'indexe correspondant au d�but du tableau dans text.
   */
  private static void tableProcess(ArrayList text, ArrayList TableData,
                                   int maxColomns, int noStartTableLine) {
    String sTable = "";
    for (int j = 0; j < TableData.size(); ++j) {
      sTable = trProcess( (ArrayList) TableData.get(j), maxColomns);
      if (j == 0) {
        sTable = "<TABLE border='1' cellspacing='0' cellpadding='0'>" + "\n" +
            sTable;
      }
      else if (j == TableData.size() - 1) {
        sTable += "</TABLE>" + "\n";
      }
      text.set(noStartTableLine + j, sTable);
    }
  }

  /**
   * Permet de traiter les balises tr d'un tableau.
   * @param listTr Liste contenant tous les �lements du noeud tr.
   * @param maxColomns Le nombre de colonnes du tableau.
   * @return Retourne une chaine repr�sentant le noeud tr avec toutes les donn�es contenues dans
   * listTr. Si le nombre de colonnes est inf�rieur � celui du tableau, le dernier �l�ment du
   * noeud tr, h�ritera d'un attribut colspan qui correspondra � la diff�rence de colonne avec
   * le tableau.
   */
  private static String trProcess(ArrayList listTr, int maxColomns) {
    String sTr = "";
    if (listTr.size() + 1 < maxColomns) {
      int iDiff = maxColomns - (listTr.size());
      String sTmp = (String) listTr.get(listTr.size() - 1);
      Matcher m = Pattern.compile("^<td[^<]+(>){1}").matcher(sTmp);
      if (m.find()) {
        int iStart = m.start();
        int iEnd = m.end();
        /*sTmp = sTmp.substring(0, iEnd - 1) + " colspan='" + (iDiff + 1) + "'>" +
            sTmp.substring(iEnd + 1);*/
      }
      listTr.set(listTr.size() - 1, sTmp);
    }
    for (int i = 0; i < listTr.size(); ++i) {
      sTr += listTr.get(i);
    }
    return "<tr>" + sTr + "\n" + "</tr>";
  }

  /**
   * Permet de traiter les balises td d'un tableau. Si le texte d'une case est englob�
   * entre deux ast�rics, le td est remplac� par 'th bgcolor='#99CCCC''. De plus, sont
   * g�r�s les alignement du texte dans la case.
   * @param sTd La chaine � traiter.
   * @return La chaine modifi� au format 'td' ou 'th'.
   */
  private static String tdProcess(String sTd) {
    String sNode = "";
    String sStartTag, sEndTag;
    Matcher m;
    if (sTd.trim().matches("\\*[^\\*]*\\*")) {
      sStartTag = "th bgcolor='#99CCCC'";
      sEndTag = "</th>";
    }
    else {
      sStartTag = "td";
      sEndTag = "</td>";
    }
    m = Pattern.compile("^[ ]*.").matcher(sTd);
    int nbStartSpace = (m.find()) ? m.end() - 1 : 0;
    m = Pattern.compile(".[ ]*$").matcher(sTd);
    int nbEndSpace = (m.find()) ? m.end() - (m.start() + 1) : 0;

    if (nbStartSpace < nbEndSpace) {
      sNode = "<" + sStartTag + " align='LEFT'";
    }
    else if (nbStartSpace > nbEndSpace) {
      sNode = "<" + sStartTag + " align='RIGHT'";
    }
    else if (nbStartSpace == nbEndSpace) {
      sNode = "<" + sStartTag + " align='CENTER'";
    }
    else {
      sNode = "<" + sStartTag;
    }
    m = Pattern.compile("([^\\|])+(?=(\\|+$))").matcher(sTd);
    if(m.find()){
      int iNbCols = sTd.length() - m.end()+1; // +1 pour le pipe qu'on a enlev�. Par defaut les cellules font 1.
      sNode += " colspan='" + iNbCols + "'>";
      sTd = sTd.substring(0, m.end());
    }
    else {
      sNode += ">";
    }
    sNode += sTd + sEndTag;

    return sNode;
  }

  /**
   * Permet de traiter les orderLists de la syntaxe twiki pour les transcrire
   * en syntaxe Html. Deplus, les diff�rents niveaux des listes sont g�r�s.
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList orderListsProcess(ArrayList text) {
    return listProcess(text, "^((   )+([0-9] ){1})", "<OL>", "</OL>");
  }

  /**
   * Permet de traiter les Lists de la syntaxe twiki pour les transcrire
   * en syntaxe Html. Deplus, les diff�rents niveaux des listes sont g�r�s.
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList listsProcess(ArrayList text) {
    return listProcess(text, "^((   )+(\\* ){1})", "<UL>", "</UL>");
  }

/** @todo Voir qu'est ce qui ce passe si la liste est sur plusieurs lignes. */
  /**
   * Permet de traiter les listes de la syntaxe twiki pour les transcrire
   * en syntaxe Html. Deplus, les diff�rents niveaux des listes sont g�r�s.
   * @param text ArrayList contenant le texte � traiter.
   * @param regex Correspond � l'expression reguli�re permettant de retrouver le tag twiki.
   * @param openningHtmlTag Balise ouvrante html qui remplace celle de twiki.
   * @param closingHtmlTag Balise fermante html qui remplace celle de twiki.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList listProcess(ArrayList text, String regex,
                                       String openningHtmlTag,
                                       String closingHtmlTag) {
    boolean isListe = false;
    int niveau = 0;
    Pattern p = Pattern.compile(regex);
    for (int i = 0; i < text.size(); ++i) {
      String sCurrentLineProcess = "";
      String sCurrentLine = (String) text.get(i);
      Matcher m = p.matcher(sCurrentLine);
      boolean result = m.find();
      if (result) {
        if (!isListe) {
          niveau = (m.end() - 2) / 3; //Nb de ' ' moins l'ast�rix.
          for (int j = 0; j < niveau; ++j) {
            sCurrentLineProcess += openningHtmlTag + "\n";
          }
          isListe = true;
        }

        int iNiveau = (m.end() - 2) / 3;

        if (niveau < iNiveau) {
          iNiveau -= niveau;
          for (int j = 0; j < iNiveau; ++j) {
            sCurrentLineProcess += openningHtmlTag + "\n";
          }
          niveau += iNiveau;
        }
        else if (niveau > iNiveau) {
          iNiveau = niveau - iNiveau;
          for (int j = 0; j < iNiveau; ++j) {
            sCurrentLineProcess += closingHtmlTag + "\n";
          }
          niveau -= iNiveau;
        }
        sCurrentLineProcess += sCurrentLine.replaceAll(regex, "<LI>") + "</LI>";
      }
      else {
        if (isListe) {
          String sOldLine = (String) text.get(i-1);
          for (int j = 0; j < niveau; ++j) {
            sOldLine += closingHtmlTag;
          }
          text.set(i-1, sOldLine);
          sCurrentLineProcess = sCurrentLine;
          isListe = false;
        }
        else {
          sCurrentLineProcess = sCurrentLine;
        }
      }
      if ( (i == text.size() - 1) && isListe) {
        if (sCurrentLineProcess == "")
          sCurrentLineProcess = sCurrentLine;

        for (int j = 0; j < niveau; ++j) {
          sCurrentLineProcess += closingHtmlTag + "\n";
        }
      }
      text.set(i, sCurrentLineProcess);
    }
    return text;
  }

  /**
   * Permet de traiter les Listes de d�finitions de la syntaxe twiki pour les transcrire
   * en syntaxe Html.
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList definitionListsProcess(ArrayList text) {
    boolean isListe = false;
    int niveau = 0;
    Pattern p = Pattern.compile("^(   )+.*: .*");
    for (int i = 0; i < text.size(); ++i) {
      String sCurrentLineProcess = "";
      String sCurrentLine = (String) text.get(i);
      Matcher m = p.matcher(sCurrentLine);
      boolean result = m.find();
      if (result) {
        Pattern p2 = Pattern.compile("^(   )+.");
        m = p2.matcher(sCurrentLine);
        m.find();
        if (!isListe) {
          niveau = (m.end() - 1) / 3; //Nb de ' ' moins le caract�re '.'.
          for (int j = 0; j < niveau; ++j) {
            sCurrentLineProcess += "<DL>" + "\n";
          }
          isListe = true;
        }

        int iNiveau = (m.end() - 1) / 3;

        if (niveau < iNiveau) {
          iNiveau -= niveau;
          for (int j = 0; j < iNiveau; ++j) {
            sCurrentLineProcess += "<DL>" + "\n";
          }
          niveau += iNiveau;
        }
        else if (niveau > iNiveau) {
          iNiveau = niveau - iNiveau;
          for (int j = 0; j < iNiveau; ++j) {
            sCurrentLineProcess += "</DL>" + "\n";
          }
          niveau -= iNiveau;
        }
        sCurrentLine = sCurrentLine.replaceAll("^(   )+", "<DT>");
        sCurrentLine = sCurrentLine.replaceAll(": ", "</DT><DD>");
        sCurrentLine += "</DD>";
        sCurrentLineProcess += sCurrentLine;
      }
      else {
        if (isListe) {
          for (int j = 0; j < niveau; ++j) {
            sCurrentLineProcess += "</DL>" + "\n";
          }
          sCurrentLineProcess += sCurrentLine;
          isListe = false;
        }
        else {
          sCurrentLineProcess = sCurrentLine;
        }
      }
      text.set(i, sCurrentLineProcess);
    }
    return text;

  }

  /**
   * Permet de traduire les paragraphes de la
   * syntaxe twiki vers la syntaxe Html.
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList ParagraphsProcess(ArrayList text) {
    return replaceProcess(text, "^[ ]*$", "<P>");
  }

  /**
   * Permet de traiter le tag <nop> de la syntaxe twiki pour les transcrire
   * en syntaxe Html (c'est � dire le remplacer par '').
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList nopsProcess(ArrayList text) {
    text = replaceProcess(text, "<nop/>", "");
    text = replaceProcess(text, "<nop />", "");
    text = replaceProcess(text, "<nop >", "");
    return replaceProcess(text, "<nop>", "");
  }

  /**
   * Permet de traiter les tags <VERBATIM></VERBATIM> de la syntaxe twiki pour les transcrire
   * en syntaxe Html (c'est � dire le remplacer par '<PRE></PRE>').
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList verbatimsProcess(ArrayList text) {
    text = replaceProcess(text, "<VERBATIM>", "<PRE>");
    text = replaceProcess(text, "</VERBATIM>", "</PRE>");
    return text;
  }

  /**
   * Permet de traiter les s�parateur de la syntaxe twiki pour les transcrire
   * en syntaxe Html (c'est � dire le remplacer les '---' par '<HR>').
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList separatorsProcess(ArrayList text) {
    return replaceProcess(text, "-{3,}+", "<HR>");
  }

  /**
   * Permet de remplacer le tag twikiTag par le tag htmlTag dans text.
   * @param text ArrayList contenant le texte � traiter.
   * @param twikiTag Le tag twiki � remplacer.
   * @param htmlTag Le tag html qui remplace twikiTag.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList replaceProcess(ArrayList text, String twikiTag,
                                          String htmlTag) {
    for (int i = 0; i < text.size(); ++i) {
      String sCurrentLine = (String) text.get(i);
      sCurrentLine = sCurrentLine.replaceAll(twikiTag, htmlTag);
      text.set(i, sCurrentLine);
    }
    return text;
  }

  /**
   * Permet de traiter les liens twiki en liens html. Traite :
   * <PRE>
   * - Les ancres.
   * - Les wikiWords
   * - Les liens basics
   * - Les liens sp�cifiques.
   * </PRE>
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList linksProcess(ArrayList text) {
    text = anchorLinksProcess(text);
    text = wikiWordLinksProcess(text);
    text = basicLinksProcess(text);
    text = specificLinksProcess(text);
    return text;
  }

  /**
   * Permet de remplacer les ancres twiki par des ancre html dans text.
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList anchorLinksProcess(ArrayList text) {
    for (int i = 0; i < text.size(); ++i) {
      String sCurrentLineProcess = "";
      String sCurrentLine = (String) text.get(i);
      Pattern p = Pattern.compile("( |^)#[^ ]*( |$ |(?=\\<))");
      Matcher m = p.matcher(sCurrentLine);
      boolean result = m.find();
      if (result == true) {
        int startChain = 0, startRegex = 0, endRegex = 0;
        while (result) {
          startRegex = m.start();
          endRegex = m.end();
          // recuperation du d�but de la chaine (avant regex).
          sCurrentLineProcess += sCurrentLine.substring(startChain,
              startRegex);
          // Recuperation de la chaine correpondant � l'expression r�guli�re (en supprimant #.
          // L'appel de trim permet de supprimer l'espace de fin si il est pr�sent.
          String sRegex = sCurrentLine.substring(startRegex, endRegex).trim();
          sRegex = sRegex.substring(sRegex.indexOf("#") + 1, sRegex.length());
          // Construction de la chaine
          if (sRegex.length() > 0)
            sCurrentLineProcess += "<A name='" + sRegex + "'></A>";
          startChain = endRegex;
          result = m.find();
        }
        // Recuperation de la fin de la chaine.
        String sFinChaine = sCurrentLine.substring(endRegex);
        sCurrentLineProcess += (sFinChaine.startsWith(" ")) ? sFinChaine :
            " " + sFinChaine;
      }
      else {
        sCurrentLineProcess = sCurrentLine;
      }
      text.set(i, sCurrentLineProcess);
    }
    return text;
  }

  /**
   * Permet de remplacer les wikiWord par des liens html dans text.
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList wikiWordLinksProcess(ArrayList text) {  /** @todo A modifier pour prendre en compte les pages du type Twiki.TkfkfTll */
    for (int i = 0; i < text.size(); ++i) {
      String sCurrentLineProcess = "";
      String sCurrentLine = (String) text.get(i);
      Pattern p = Pattern.compile(
          "((?<= |^)(<nop>){0}([A-Z]+[a-z]+\\.)*[A-Z]+)([a-z]+)([A-Z][^ $\\.\\?!\\<]*)");
      Matcher m = p.matcher(sCurrentLine);
      boolean result = m.find();
      if (result) {
        int startChain = 0;
        while (result) {
          int startRegex = m.start();
          int endRegex = m.end();
          // recuperation du d�but de la chaine (avant regex).
          String sBegin = sCurrentLine.substring(startChain, startRegex);

          sCurrentLineProcess += (sBegin.equals("")) ? "<A HREF='" :
              sBegin + "<A HREF='";
          // Recuperation de la chaine propre au nop moins l'espace de devant.
          String sWikiWord = sCurrentLine.substring(startRegex, endRegex).trim();
          sCurrentLineProcess +=  sWikiWord+ "' class='"+HtmlTwikiResource.WIKIWORDCLASS+"'>"+sWikiWord+"</A>";
          startChain = endRegex;
          result = m.find();
          if (!result) {
            sCurrentLineProcess += sCurrentLine.substring(endRegex);
          }
        }
      }
      else {
        sCurrentLineProcess = sCurrentLine;
      }
      text.set(i, sCurrentLineProcess);
    }
    return text;
  }

  /**
   *
   * @param sChaine
   * @return
   */
  private static String wikiWordProcess(String sRegex){
    String sChaine = null;
    Matcher mWikiWord = Pattern.compile( "((?<= |^)(<nop>){0}([A-Z]+[a-z]+\\.)*[A-Z]+)([a-z]+)([A-Z][^ $\\.\\?!\\<]*)").matcher(sRegex);
    if (mWikiWord.find()) {
      sChaine = sRegex.substring(mWikiWord.start(), mWikiWord.end()).trim();
    }
    return sChaine;
  }

  /**
   * Permet de remplacer les liens sp�cifiques twiki en lien html dans text.
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList basicLinksProcess(ArrayList text) {
    for (int i = 0; i < text.size(); ++i) {
      String sCurrentLineProcess = "";
      String sCurrentLine = (String) text.get(i);
      Pattern p = Pattern.compile("(\\[\\[)[^\\]\\[]*(\\]\\])");
      Matcher m = p.matcher(sCurrentLine);
      boolean result = m.find();
      if (result) {
        int startChain = 0;
        while (result) {
          int startRegex = m.start();
          int endRegex = m.end();
          // recuperation du d�but de la chaine (avant regex).
          sCurrentLineProcess += sCurrentLine.substring(startChain, startRegex);

          String sRegex = sCurrentLine.substring(startRegex, endRegex);
          sRegex = sRegex.substring("[[".length(),
                                    sRegex.length() - "]]".length());

          // Recherche de wikiword.
          String sChaine = wikiWordProcess(sRegex);

          if(sChaine==null){ //sRegex n'est pas un wikiWord
            sCurrentLineProcess += "<A HREF='" + sRegex + "'>" + sRegex +
                "</A>";
          }else{ //sRegex est un wikiWord
            sCurrentLineProcess += "<A HREF='" + sChaine + "' class='"+HtmlTwikiResource.WIKIWORDCLASS+"'>" + sChaine +
                "</A>";
          }
          startChain = endRegex;
          result = m.find();
          if (!result) {
            sCurrentLineProcess += sCurrentLine.substring(endRegex);
          }
        }
      }
      else {
        sCurrentLineProcess = sCurrentLine;
      }
      text.set(i, sCurrentLineProcess);
    }
    return text;
  }

  /**
   * Permet de remplacer les liens sp�cifiques twiki en lien html dans text.
   * @param text ArrayList contenant le texte � traiter.
   * @return Retourne l'ArrayList contenant toutes les modifs.
   */
  private static ArrayList specificLinksProcess(ArrayList text) {
    for (int i = 0; i < text.size(); ++i) {
      String sCurrentLineProcess = "";
      String sCurrentLine = (String) text.get(i);
      Pattern p = Pattern.compile(
          "(\\[\\[)[^\\]\\[]*(\\]\\[){1}[^\\]\\[]*(\\]\\])");
      Matcher m = p.matcher(sCurrentLine);
      boolean result = m.find();
      if (result) {
        int startChain = 0;
        while (result) {
          int startRegex = m.start();
          int endRegex = m.end();
          // recuperation du d�but de la chaine (avant regex).
          sCurrentLineProcess += sCurrentLine.substring(startChain, startRegex);

          String sRegex = sCurrentLine.substring(startRegex, endRegex);
          sRegex = sRegex.substring("[[".length(),
                                    sRegex.length() - "]]".length());
          int index = sRegex.indexOf("][");
          if (index != -1){
            // Recherche de wikiword.
            String sChaine = wikiWordProcess(sRegex.substring(0, index));

            if(sChaine==null){ //sRegex n'est pas un wikiWord
              sCurrentLineProcess += "<A HREF='" + sRegex.substring(0, index) +
                "'>" + sRegex.substring(index + 2) + "</A>";
            }else{ //sRegex est un wikiWord
              sCurrentLineProcess += "<A HREF='" + sChaine + "' class='"+HtmlTwikiResource.WIKIWORDCLASS+"'>" + sRegex.substring(index + 2) +
                  "</A>";
            }
          }
          startChain = endRegex;
          result = m.find();
          if (!result) {
            sCurrentLineProcess += sCurrentLine.substring(endRegex);
          }
        }
      }
      else {
        sCurrentLineProcess = sCurrentLine;
      }
      text.set(i, sCurrentLineProcess);
    }
    return text;
  }

  /**
   * M�thode principale du programme.
   * @param arg Un argument pr�cisant le fichier � traduire.
   */
  public static void main(String[] arg) {
    FileInputStream fis = null;
    try {
      if (arg[0] != null) {
        fis = new FileInputStream(new File(arg[0]));
        String result = TwikiToHtml.translate(fis);
        System.out.println(result);
      }
      else {
        System.out.println("TwikiToHtml : File not found!!");
      }
    }
    catch (FileNotFoundException ex) {
      System.out.println("TwikiToHtml => FileNotFoundException");
    }
    catch (Exception ex) {
      System.out.println("An error is appeared!!!");
    }
  }
}
