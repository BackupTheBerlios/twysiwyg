/**
 * <p>Titre : Parsing de la syntaxe html vers la syntaxe twiki.</p>
 * <p>Description : Permet de transcrire un fichier sous la syntaxe html vers la syntaxe twiki.</p>
 * <p>Copyright : Copyright (c) 2003</p>
 * <p>Soci�t� : iutForce</p>
 * @author Fr�d�ric Luddeni (frederic.luddeni@wanadoo.fr)
 * @version 1.06
 *
 * <PRE>
 * Cette classe permet de traduire un fichier suivant la syntaxe html en syntaxe twiki. Lors de la lecture
 * du fichier, le fichier htmlest pars� par l'interm�diaire de jtidy pour permettre de corriger les �ventuelles
 * erreurs syntaxique.
 *
 * - Todo :
 *   * Prendre en charge les variables twiki (exemple %TOC%).
 *   * Supprimer les ancres r�sultantes de %TOC% (ex.: pour les titres) (Attendre la prise en charge des variables).
 *
 * Version 1.06 :
 * --------------
 *    * Prise en charge de l'attribut 'class' avec les wikiWords.
 * - Modifs:
 *    * isTwikiTable avec ajouts de contr�les.
 *    * Modification de listeItemProcess pour prendre en compte les orderList.
 *    * Modification de listProcess maintenant, les lists et orderlists passent par elle.
 *    * Modif de listeItemProcess erreur avec les 3 espaces.
 * - Suppression:
 *    * orderlistProcess remplac�e par listProcess.
 *
 * Version 1.05 :
 * --------------
 * - Modifs:
 *    * isTwikiTable : Pour ne plus remplacer les tableaux qui n'ont pas d'attribut border par defaut.
 *    * Les m�thodes translate ne retournent plus que le contenu de la balise body:
 *      * Modif de HtmlTagProcess pour ne pas afficher le tag body.
 *      * Modifs de translate(FileInputStream fis, PrintWriter errout) pour ne r�cuperer que le noeud
 *        propre au tag body.
 *    * Mdifs des m�thodes translate en leur ajoutant un attribut "showWarnings" qui permet de sp�cifier
 *      si on veut que les warnings soient affich�s.
 *
 * Version 1.04 :
 * --------------
 * - Ajout:
 *    * isTwikiTable : Permet de savoir si le tableau doit �tre traduit ou pas.
 * - Modifs:
 *    * Remplacement de <BR/> par "<BR>.
 *    * simpleHtmlTagProcess en ajoutant un booleen ''.
 *    * listeItemProcess : Il y avait un niveau de trop initialis�.
 *    * tableProcess : Pour savoir si il faut la traduire en twiki ou pas.
 *
 * Version 1.03 :
 * --------------
 * - Modifs:
 *    * listeItemProcess : Verif de...
 *    * Modif de translate.
 *    * Ajout de translate(String sText).
 *    * orderListProcess (supprimer un bug : remplacement de newLine par bNewLine)
 *    * translate avec ajout de errout.
 *
 *
 * Version 1.02 :
 * --------------
 * - Modifs:
     *   * Modification g�n�rale des m�thodes pour traiter les whitespaces characters
 *     (par exemple ne pas prendre en compte un \n dans un titre).
 *   * Modification g�n�rale des m�thodes pour savoir, lors du traitement d'un nouveau noeud
 *     si on se trouve sur une nouvelle ligne. Permet de cr�er une nouvelle ligne ou pas si n�cessaire.
 *   * ajout d'un booleen (bNewLine) dans getChildrenProcess pour savoir s'il y a eu un \n dans l'�tape
 *     pr�c�dente.
 *   * Affiche les fils d'une liste lorsqu'une liste imbriqu�e est pr�sente.
 *   * Affichage des styles : correction styleProcess, fixedFontProcess.
 *   * Affichage des liens am�lior�.
 *   * tableProcess : prise en charge la balise TBODY.
 *   * trProcess : prise en charge la balise TH.
 *   * nopProcess : Am�lioration de l'expression reguli�re.
 *   * linkProcess : Suppresion des nop dans les cha�nes.
 *
 * Version 1.01 :
 * --------------
 * - Modifs :
 *   * linkProcess : Correction du bug sur les ancres.
 *   * tdProcess : Am�lioration du code en rempla�ant la boucle sur la liste des attributs par getNamedItem().
 *
 * Version 1:
 * ----------
 * Processed :
 * - Paragraphs 'Blanck line'.
 * - Headings '---+', '---++', '---+++', '---++++', '---+++++' et '---++++++'.
 * - Bold Text '*boldText*'.
 * - Italic Text '_italicText_'.
 * - Bold Italic Text __boldItalicText__'.
 * - Fixed Font '=fixedFont='.
 * - Bold Fixed Font '==boldFixedFont=='.
 * - Verbatim Mode '\n<VERBATIM>\n</VERBATIM>\n'.
 * - Separator '---'.
 * - Prevent a Link '<nop>.
 * - List Item.
 * - Nested List Item.
 * - Ordered List.
 * - Definition List.
 * - Table.
 * - Forced Links, WikiWord Links, Specific Links, Anchors.
 * </PRE>
 */
package twe.translator;

import java.io.*;
import java.util.regex.*;
import org.w3c.dom.*;
import org.w3c.dom.Node;
import org.w3c.tidy.*;

public class HtmlToTwiki {

  private static String LIST_TWIKI_TAG = "*";
  private static String ORDERLIST_TWIKI_TAG = "1";
  private HtmlToTwiki() throws FileNotFoundException {
  }

  /**
   * M�thode principale de la classe qui permet de lancer la traduction d'un fichier
   * au format html.
   * Le fichier est d'abord pars� par la biblioth�que jtidy pour corriger les erreurs
   * syntaxique puis il est traduit en twiki.
   * @param sText Texte � traduire en syntaxe twiki.
   * @param errout Flux o� sera affich� les erreurs de syntaxe html. Si � null, alors par d�faut,
   * @param showWarnings Permet de sp�cifier si on veut que les warnings soient affich�s ou pas dans
   * errout.
   * les erreurs seront affich�e sur le flux standard d'erreur.
   * @return Une string repr�sentant le contenu du fichier traduit en twiki.
   * @throws FileNotFoundException Lev� si le chemin du fichier 'filePath' n'est pas
   * valide.
   * @throws IOException Lev� si un probl�me survient lors de l'initialisation du parsing.
   */
  public static String translate(String sText, PrintWriter errout,
                                 boolean showWarnings) throws
      FileNotFoundException, IOException {
    File temp = File.createTempFile("HtmlToTwiki", ".tmp");
    temp.deleteOnExit();
    PrintWriter msg = new PrintWriter(new FileWriter(temp));
    msg.print(sText);
    msg.close();
    return translate(new FileInputStream(temp), errout, showWarnings);
  }

  /**
   * M�thode principale de la classe qui permet de lancer la traduction d'un fichier
   * au format html.
   * Le fichier est d'abord pars� par la biblioth�que jtidy pour corriger les erreurs
   * syntaxique puis il est traduit en twiki.
   * @param fis Le flux du fichier html � traduire en syntaxe twiki.
   * @param errout Flux o� sera affich� les erreurs de syntaxe html. Si null,
   * @param showWarnings Permet de sp�cifier si on veut que les warnings soient affich�s ou pas dans
   * errout.
   * les erreurs seront affich�es dans le flux standard d'erreur.
   * @return Une string repr�sentant le contenu du fichier traduit en twiki.
   * @throws FileNotFoundException Lev� si le chemin du fichier 'filePath' n'est pas
   * valide.
   */
  public static String translate(FileInputStream fis, PrintWriter errout,
                                 boolean showWarnings) throws
      FileNotFoundException {
    Tidy tidy = new Tidy();
    tidy.setShowWarnings(showWarnings);
    tidy.setMakeClean(true);
    tidy.setXHTML(true);
    if (errout != null) {
      tidy.setErrout(errout);
    }
    //return processTranslate(tidy.parseDOM(fis, null), true, true);
    Document document = tidy.parseDOM(fis, null);
    NodeList nodeList = document.getElementsByTagName("body");
    return processTranslate( (nodeList.getLength() == 1) ? nodeList.item(0) :
                            document, true, true);
  }

  public static String translate(FileInputStream fis) throws
      FileNotFoundException {
    return translate(fis, null, false);
  }

  /**
   * Permet de savoir si sText finit par une nouvelle ligne.
   * @param sText Le texte � tester.
   * @return true si le texte finit par une nouvelle ligne, false sinon.
   */
  private static boolean isNewLine(String sText) {
    return sText.endsWith("\n");
  }

  private static String specialCharProcess(String sText){
    sText = sText.replaceAll("�", "&eacute;");
    sText = sText.replaceAll("�", "&eacute;");
    sText = sText.replaceAll("�", "&egrave;");
    sText = sText.replaceAll("�", "&ecirc;");
    sText = sText.replaceAll("�", "&agrave;");
    sText = sText.replaceAll("�", "&acirc;");
    sText = sText.replaceAll("�", "&ccedil;");
    sText = sText.replaceAll("�", "&icirc;");
    sText = sText.replaceAll("�", "&ocirc;");
    sText = sText.replaceAll("�", "&ugrave;");
    sText = sText.replaceAll("�", "&ucirc;");

    return sText;
  }
  /**
   * M�thode permettant de lancer la traduction de chaque noeud.
   * @param node Le noeud � traduire.
   * @param activeSpace Permet de savoir si les caract�res d'echappement doivent
   * �tre repr�sent�s ou pas.
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String processTranslate(Node node, boolean activeSpace,
                                         boolean newLine) {
    String sText = "";
    if (node == null)
      return "";

    int type = node.getNodeType();
    switch (type) {
      // Cas d'un noeud principal.
      case Node.DOCUMENT_NODE:
        sText = processTranslate( ( (Document) node).getDocumentElement(),
                                 activeSpace, newLine);
        break;
        // Cas d'une balise ouvrante.
      case Node.ELEMENT_NODE:
        sText = nodeProcess(node, activeSpace, newLine);
        break;
        // Cas permettant de r�cuperer le texte compris entre des balises.
      case Node.TEXT_NODE:
        String sNodeValue = node.getNodeValue();
        sNodeValue = specialCharProcess(sNodeValue);
        if (!activeSpace) {
          sNodeValue = sNodeValue.replaceAll("([ ]+|[ \t\n\f\r])", " ");
        }
        if (!sNodeValue.trim().equals("\n") && !sNodeValue.trim().equals("")) {
          sText = nopProcess(sNodeValue);
        }
        break;
    }
    return sText;
  }

  /**
       * Permet de traiter sNodeValue pour prot�ger les mots ayant le type WikiWord.
   * @param sNodeValue La phrase � analyser pour prot�ger les mots ayant le type WikiWord.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String nopProcess(String sNodeValue) {
    String sText = "";
    Pattern p = Pattern.compile("(( |^)[A-Z]+)([a-z]+)([A-Z]+)");
    Matcher m = p.matcher(sNodeValue);
    boolean result = m.find();
    if (result) {
      int startChain = 0;
      while (result) {
        int startRegex = m.start();
        int endRegex = m.end();
        // recuperation du d�but de la chaine (avant regex).
        String sBegin = sNodeValue.substring(startChain, startRegex);
        sText += (sBegin.equals("")) ? "<nop>" : sBegin + " <nop>";
        // Recuperation de la chaine propre au nop moins l'espace de devant.
        sText += sNodeValue.substring(startRegex, endRegex).trim();
        startChain = endRegex;
        result = m.find();
        if (!result) {
          sText += sNodeValue.substring(endRegex);
        }
      }
    }
    else {
      sText = sNodeValue;
    }
    return sText;
  }

  /**
   * Permet le traitment des noeuds correspondant � des �l�ments.
   * @param node Le noeud � traiter.
       * @param activeSpace Permet de savoir si les caract�res d'echappement doivent
   * �tre repr�sent�s ou pas.
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String nodeProcess(Node node, boolean activeSpace,
                                    boolean newLine) {
    String sNode = node.getNodeName();

    if (sNode.toUpperCase().equals("H1")) {
      return titleProcess(node, "---+", newLine);
    }
    else if (sNode.toUpperCase().equals("H2")) {
      return titleProcess(node, "---++", newLine);
    }
    else if (sNode.toUpperCase().equals("H3")) {
      return titleProcess(node, "---+++", newLine);
    }
    else if (sNode.toUpperCase().equals("H4")) {
      return titleProcess(node, "---++++", newLine);
    }
    else if (sNode.toUpperCase().equals("H5")) {
      return titleProcess(node, "---+++++", newLine);
    }
    else if (sNode.toUpperCase().equals("H6")) {
      return titleProcess(node, "---++++++", newLine);
    }
    else if (sNode.toUpperCase().equals("B") ||
             sNode.toUpperCase().equals("STRONG")) {
      return styleProcess(node, sNode.toUpperCase(), activeSpace, newLine);
    }
    else if (sNode.toUpperCase().equals("I") || sNode.toUpperCase().equals("EM")) {
      return styleProcess(node, sNode.toUpperCase(), activeSpace, newLine);
    }
    else if (sNode.toUpperCase().equals("CODE")) {
      return fixedFontProcess(node, activeSpace, newLine);
    }
    else if (sNode.toUpperCase().equals("PRE")) {
      return verbatimProcess(node, newLine);
    }
    else if (sNode.toUpperCase().equals("P") ||
             sNode.toUpperCase().equals("BLOCKQUOTE")) {
      return paragraphProcess(node, newLine);
    }
    else if (sNode.toUpperCase().equals("UL")) {
      return listProcess(node, LIST_TWIKI_TAG, 1, newLine);
    }
    else if (sNode.toUpperCase().equals("OL")) {
      //return orderListProcess(node, newLine);
      return listProcess(node, ORDERLIST_TWIKI_TAG, 1, newLine);
    }
    else if (sNode.toUpperCase().equals("DL")) {
      return definitionListProcess(node, newLine);
    }
    else if (sNode.toUpperCase().equals("A")) {
      return linkProcess(node);
    }
    else if (sNode.toUpperCase().equals("TABLE")) {
      return tableProcess(node, newLine);
    }
    else if (sNode.toUpperCase().equals("HR")) {
      return simpleHtmlTagProcess("---", activeSpace, newLine);
    }
    else if (sNode.toUpperCase().equals("BR")) {
      return simpleHtmlTagProcess("<BR>", true, newLine);
    }
    else {
      // Cas d'une balise html avec aucune correspondance Twiki.
      sNode = HtmlTagProcess(node, activeSpace, newLine);
    }
    return sNode;
  }

  /**
   * Permet de retourner les tags html qui ne peuvent �tre traduit en twiki.
   * @param node Le noeud correspondant au tag html.
       * @param activeSpace Permet de savoir si les caract�res d'echappement doivent
   * �tre repr�sent�s ou pas.
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une cha�ne contenant le tag html et son contenu.
   */
  private static String HtmlTagProcess(Node node, boolean activeSpace,
                                       boolean newLine) {
    String sNode = (activeSpace && !newLine) ? "\n" : "";
    String sNameNode = node.getNodeName();
    if (!sNameNode.equalsIgnoreCase("body")) {
      sNode += "<" + sNameNode;

      NamedNodeMap attrs = node.getAttributes();
      for (int i = 0; i < attrs.getLength(); i++) {
        String sAttribut = " " + attrs.item(i).getNodeName() + "=\"" +
            attrs.item(i).getNodeValue() + "\"";

        sNode += sAttribut;
      }
      sNode += (!activeSpace) ? ">" : ">\n";

      sNode += getChildrenProcess(node, activeSpace, activeSpace);

      // Balise fermante.
      String sClosingTag = "</" + sNameNode;
      sClosingTag += (!activeSpace) ? ">" : ">\n";
      sNode += sClosingTag;
    }
    else {
      sNode += getChildrenProcess(node, activeSpace, activeSpace);
    }

    return sNode;
  }

  /**
   * Permet de traiter les noeuds fils du noeud 'node'.
   * @param node Le noeud dont on veut traiter ses fils
       * @param activeSpace Permet de savoir si les caract�res d'echappement doivent
   * �tre repr�sent�s ou pas.
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
       * @return Une string retournant la cha�ne correspondant aux fils du noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String getChildrenProcess(Node node, boolean activeSpace,
                                           boolean newLine) {
    String sNode = (activeSpace && !newLine) ? "\n" : "";
    NodeList children = node.getChildNodes();
    if (children != null) {
      int len = children.getLength();
      boolean bNewLine = newLine;
      for (int i = 0; i < len; i++) {
        //if (node.getNodeName().equalsIgnoreCase("body"))
        sNode += processTranslate(children.item(i), activeSpace, bNewLine);
        bNewLine = isNewLine(sNode);
      }
    }
    return sNode;
  }

  /**
   * Permet de traduire les tags repr�sentant les titres.
   * @param node Le noeud correspondant au tag du titre � traiter.
   * @param tagTitle Le tag twiki qui remplace le tag html.
   * @param newLine permet de savoir si on se situe sur une nouvelle ligne. True si c le cas false sinon.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String titleProcess(Node node, String tagTitle,
                                     boolean newLine) {
    String sNode = tagTitle;
    sNode += getChildrenProcess(node, false, newLine);
    return (!newLine) ? "\n" + sNode + "\n" : sNode + "\n";
  }

  /**
   * Permet de traiter les liens hypertextes. C'est � dire le tags Html 'A'.
   * @param node Le noeud correspondant au tag 'A' � traiter.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String linkProcess(Node node) {
    String sNode = "";
    boolean bContinue = true, SimpleTwikiWord = false;
    NamedNodeMap attrs = node.getAttributes();
    String sNodeValue = "";
    sNodeValue +=
        getChildrenProcess(node, false,
                           false).replaceAll("([ ]+|[ \t\n\f\r]|<nop>)",
                                             " ").trim();
    if (attrs != null) {
      Node nHref = attrs.getNamedItem("href");
      Node nName = attrs.getNamedItem("name");
      Node nClass = attrs.getNamedItem("class");

      if (nHref != null) {
        String sTmpUrl = nHref.getNodeValue().replaceAll("([ ]+|[ \t\n\f\r])",
            " ");

        // Cas des TwikiWords.
        if (nClass != null &&
            (nClass.getNodeValue().equalsIgnoreCase(HtmlTwikiResource.
            WIKIWORDCLASS))) {
          sTmpUrl = sTmpUrl.replaceFirst("(.*/(?=[^/]+$))", "");
          /** @todo Verifier si href est un TwikiWord et si dans ce cas href=name*/
          if (sTmpUrl.equalsIgnoreCase(sNodeValue)) {
            sNode = sTmpUrl;
            SimpleTwikiWord = true;
          }
          bContinue = false;
        }

        if (!SimpleTwikiWord)
          sNode = "[" + sTmpUrl + "]";
      }
      else if (nName != null && bContinue) {
        String sName = nName.getNodeValue().replaceAll("([ ]+|[ \t\n\f\r])",
            " ");
        sName = (!sName.startsWith("#")) ? "#" + sName : sName;

        sNode += sName + " " + getChildrenProcess(node, false, false);
        return sNode;
      }

      // Verifier si La valeur du lien doit �tre inser�e pour completer le lien.
      if (!sNodeValue.equals("") && !SimpleTwikiWord) {
        if (!sNode.equalsIgnoreCase(sNodeValue)) {
          sNode = "[" + sNode + "[" + sNodeValue + "]]";
        }
        else {
          sNode = "[" + sNode + "]";
        }
      }
    }
    return sNode;
  }

  /**
   * Permet de traiter les tags paragraphes 'P' ou 'BR'.
   * @param node Le noeud correspondant au tag 'P' ou 'BR' � traiter.
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String paragraphProcess(Node node, boolean newLine) {
    String sNode = (newLine) ? "\n" : "\n\n";
    sNode += getChildrenProcess(node, true, true);
    sNode += (!isNewLine(sNode)) ? "\n" : "";
    return sNode;
  }

  /**
   * Permet de traiter les tags html n'ayant pas besoin de balise fermante et
   * de traitement sp�cifique (ex.:'HR', 'BR').
   * @param twikiTag La balise � traduire.
       * @param activeSpace Permet de savoir si les caract�res d'echappement doivent
   * �tre repr�sent�s ou pas.
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une string retournant la cha�ne correspondant � la traduction de twikiTag.
   */
  private static String simpleHtmlTagProcess(String twikiTag,
                                             boolean activeSpace,
                                             boolean newLine) {
    String sNode = (activeSpace && !newLine) ? "\n" : "";
    sNode += twikiTag;
    sNode += (activeSpace) ? "\n" : "";
    return sNode;

  }

  /**
   * Permet de traduire les tags preformat�s 'PRE'.
   * @param node Le noeud correspondant au tag 'PRE' � traiter.
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String verbatimProcess(Node node, boolean newLine) {
    String sNode = (!newLine) ? "\n" : "";
    sNode += "<VERBATIM>\n";
    sNode += getChildrenProcess(node, true, true);
    sNode += (!isNewLine(sNode)) ? "\n" : "";
    sNode += "</VERBATIM>\n";
    return sNode;
  }

  /**
   * Permet de traduire les tags repr�sentant le style fixed font. Si une balise html de type gras
   * est d�tect�e, ces tags sont automatiquement remplac�s par la syntaxe twiki
   * propre au style bold fixed font.
   * @param node Le noeud correspondant au tag du style � traiter.
       * @param activeSpace Permet de savoir si les caract�res d'echappement doivent
   * �tre repr�sent�s ou pas.
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String fixedFontProcess(Node node, boolean activeSpace,
                                         boolean newLine) {
    String sNode = (activeSpace && !newLine) ? "\n" : "";
    NodeList children = node.getChildNodes();
    if (children != null) {
      if (children.getLength() == 1 &&
          (children.item(0).getNodeName().toUpperCase().equals("B") ||
           children.item(0).getNodeName().toUpperCase().equals("STRONG"))) {
        sNode = " ==";
        sNode += getChildrenProcess(children.item(0), false, false);
        sNode += "== ";
      }
      else {
        sNode = " =";
        sNode += getChildrenProcess(node, false, false);
        sNode += "= ";
      }
    }
    return sNode;
  }

  /**
   * Permet de traduire les tags repr�sentant les style Gras,
   * Italique et Gras-Italique. de plus, si une balise 'CODE' est d�tect�e apr�s une
   * balise de type gras, ces tags sont automatiquement remplac�s par la syntaxe twiki
   * propre au style bold fixed font.
   * @param node Le noeud correspondant au tag du style � traiter.
   * @param sTag Le tag � traiter sous forme html ('B', 'STRONG', 'I' ou 'EM').
       * @param activeSpace Permet de savoir si les caract�res d'echappement doivent
   * �tre repr�sent�s ou pas.
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String styleProcess(Node node, String sTag,
                                     boolean activeSpace, boolean newLine) {
    String sNode = (activeSpace && !newLine) ? "\n" : "";
    String sOtherTag = ""; // The other tag which allow to use the twiki tag '__'.
    String sOtherTag2 = "";
    String sTwikiTag = "";
    boolean verifFixedFontProcess = false;
    if (sTag.toUpperCase().equals("B") || sTag.toUpperCase().equals("STRONG")) {
      sOtherTag = "I";
      sOtherTag2 = "EM";
      sTwikiTag = "*";
      verifFixedFontProcess = true;
    }
    else {
      if (sTag.toUpperCase().equals("I") || sTag.toUpperCase().equals("EM")) {
        sOtherTag = "B";
        sOtherTag2 = "STRONG";
        sTwikiTag = "_";
      }
      else {
        System.err.println("The tag is not valid. To manage the styleProcess.");
      }
    }
    NodeList children = node.getChildNodes();
    if (children != null) {
      if (children.getLength() == 1) {
        if (children.item(0).getNodeName().toUpperCase().equals(sOtherTag) ||
            children.item(0).getNodeName().toUpperCase().equals(sOtherTag2)) {
          sTwikiTag = "__";
          node = children.item(0);
        }
        else {
          if (verifFixedFontProcess) {
            if (children.item(0).getNodeName().toUpperCase().equals("CODE")) {
              sTwikiTag = "==";
              node = children.item(0);
            }
          }
        }
      }
      sNode = " " + sTwikiTag;
      sNode += getChildrenProcess(node, false, false);
      sNode += sTwikiTag + " ";
      //sNode += (activeSpace)?"\n":"";
    }
    return sNode;
  }

      /****************************************************************************/
      /**************************** LIST PROCESS **********************************/
      /****************************************************************************/

  /**
   * Permet de traiter les listes. C'est � dire le tags Html 'UL'.
   * @param node Le noeud correspondant au tag 'UL' � traiter.
   * @param niveau Le niveau des items (correspond � l'indentation des puces).
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String listProcess(Node node, String sTwikiTag, int niveau,
                                    boolean newLine) {
    String sNode = "";
    NodeList children = node.getChildNodes();
    if (children != null) {
      int len = children.getLength();
      boolean bNewLine = newLine;
      for (int i = 0; i < len; i++) {
        if (children.item(i).getNodeName().toUpperCase().equals("LI")) {
          sNode +=
              listeItemProcess(children.item(i), sTwikiTag, niveau, bNewLine);
        }
        else {
          sNode += processTranslate(children.item(i), false, bNewLine);
        }
        bNewLine = isNewLine(sNode);
      }
    }
    return sNode;
  }

  /**
       * Permet de traiter les �l�ments d'une liste. C'est � dire le tags Html 'LI'.
   * @param node Le noeud correspondant au tag 'LI' � traiter.
   * @param niveau Le niveau des items (correspond � l'indentation des puces).
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String listeItemProcess(Node node, String sTwikiTag,
                                         int niveau, boolean newLine) {
    String sNode = "";
    for (int i = 0; i < niveau; ++i) {
      sNode = sNode + "   ";
    }
    sNode = (!newLine) ? "\n" + sNode + sTwikiTag + " " :
        sNode + sTwikiTag + " ";
    NodeList children = node.getChildNodes();
    if (children != null) {
      int len = children.getLength();
      boolean bNewLine = isNewLine(sNode);
      for (int i = 0; i < len; i++) {
        if (children.item(i).getNodeName().toUpperCase().equals("UL")) {
          if (sNode.trim().equals(sTwikiTag)) {
            sNode = listProcess(children.item(i), LIST_TWIKI_TAG, niveau + 1,
                                bNewLine);
          }
          else {
            sNode +=
                listProcess(children.item(i), LIST_TWIKI_TAG, niveau + 1,
                            bNewLine);
          }
        }
        else if (children.item(i).getNodeName().toUpperCase().equals("OL")) {
          if (sNode.trim().equals(sTwikiTag)) {
            sNode = listProcess(children.item(i), ORDERLIST_TWIKI_TAG,
                                niveau + 1, bNewLine);
          }
          else {
            sNode +=
                listProcess(children.item(i), ORDERLIST_TWIKI_TAG, niveau + 1,
                            bNewLine);
          }
        }
        else {
          sNode += processTranslate(children.item(i), false, false);
        }
        bNewLine = isNewLine(sNode);
      }
    }
    return sNode;
  }

  /**
       * Permet de traiter les listes de d�finitions. C'est � dire le tags Html 'DL'.
   * @param node Le noeud correspondant au tag 'DL' � traiter.
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String definitionListProcess(Node node, boolean newLine) {
    String sNode = "";
    NodeList children = node.getChildNodes();
    if (children != null) {
      int len = children.getLength();
      boolean bNewLine = newLine;
      for (int i = 0; i < len; i++) {
        if (children.item(i).getNodeName().toUpperCase().equals("DT")) {
          sNode += (!bNewLine) ? "\n" : "";
          sNode += "   ";
          sNode += getChildrenProcess(children.item(i), false, bNewLine).
              replaceAll(" ", "&nbsp;");
        }
        if (children.item(i).getNodeName().toUpperCase().equals("DD")) {
          sNode += ": " +
              getChildrenProcess(children.item(i), false, bNewLine).
              replaceAll(" ", "&nbsp;");
          sNode += (!isNewLine(sNode)) ? "\n" : "";
        }
        bNewLine = isNewLine(sNode);
      }
    }
    return sNode;
  }

      /****************************************************************************/
      /*************************** TABLE PROCESS **********************************/
      /****************************************************************************/

  /**
       * Permet de traiter les tableaux et plus particuli�rement les tags Html 'TABLE'.
   * @param node Le noeud correspondant au tag 'TABLE' � traiter.
   * @param newLine Permet de savoir si on est plac� sur une nouvelle ligne.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String tableProcess(Node node, boolean newLine) {
    String sNode = (!newLine) ? "\n" : "";
    if (isTwikiTable(node)) {
      NodeList children = node.getChildNodes();
      if (children != null) {
        int len = children.getLength();
        for (int i = 0; i < len; i++) {
          if (children.item(i).getNodeName().toUpperCase().equals("TBODY")) {
            sNode += tableProcess(children.item(i), newLine);
          }
          else if (children.item(i).getNodeName().toUpperCase().equals("TR")) {
            sNode += trProcess(children.item(i));
          }
        }
      }
    }
    else {
      sNode = HtmlTagProcess(node, true, newLine);
    }
    return sNode + "\n"; // "\n" : Pour �viter de coller deux tableaux
  }

  /**
   * Permet de savoir si le tableau, correspondant � un node, doit �tre traduit ou pas.
   * @param node Le noeud representant le tableau.
   * @return true si le tableau est conforme � la syntaxe twiki.
   */
  private static boolean isTwikiTable(Node node) {
    boolean bTwiki = true;
    NamedNodeMap attrs = node.getAttributes();
    if (attrs != null &&
        !node.getNodeName().toUpperCase().equals(
        "TBODY")) {
      Node nBorder = attrs.getNamedItem("border");
      bTwiki = (nBorder == null ||
                Integer.parseInt(nBorder.getNodeValue()) != 1) ? false : true;
    }
    if (bTwiki) {
      NodeList tableChildren = node.getChildNodes();
      if (tableChildren != null) {
        for (int i = 0; i < tableChildren.getLength(); i++) {
          if (tableChildren.item(i).getNodeName().toUpperCase().equals("TR")) {
            NodeList TrChildren = tableChildren.item(i).getChildNodes();
            if (TrChildren != null) {
              for (int j = 0; j < TrChildren.getLength(); j++) {
                if (TrChildren.item(j).getNodeName().toUpperCase().equals(
                    "TD") ||
                    TrChildren.item(j).getNodeName().toUpperCase().equals(
                    "TH")) {
                  NamedNodeMap attrsChildren = TrChildren.item(j).getAttributes();
                  if (attrs != null) {
                    Node nRowspan = attrsChildren.getNamedItem("rowspan");
                    bTwiki = (nRowspan != null &&
                              Integer.parseInt(nRowspan.getNodeValue()) != 1) ? false : true;
                  }
                }
                if (!bTwiki)
                  break;
              }
            }
          }
          else {
            if (tableChildren.item(i).getNodeName().toUpperCase().equals(
                "TBODY")) {
              bTwiki = isTwikiTable(tableChildren.item(i));
            }
          }
          if (!bTwiki)
            break;
        }
      }
    }
    return bTwiki;
  }

  /**
   * Permet de traiter les tags Html 'TR'.
   * @param node Le noeud correspondant au tag 'TR' � traiter.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String trProcess(Node node) {
    String sNode = "";
    NodeList children = node.getChildNodes();
    if (children != null) {
      int len = children.getLength();
      for (int i = 0; i < len; i++) {
        if (children.item(i).getNodeName().toUpperCase().equals("TD") ||
            children.item(i).getNodeName().toUpperCase().equals("TH")) {
          sNode += tdProcess(children.item(i));
        }
      }
      sNode += "|\n";
    }
    return sNode;
  }

  /**
   * Permet de traiter les tags Html 'TD'.
   * @param node Le noeud correspondant au tag 'TD' � traiter.
   * @return Une string retournant la cha�ne correspondant au noeud 'node'
   * traduit en syntaxe twiki.
   */
  private static String tdProcess(Node node) {
    String sNode = "";
    String sStartLine = "  ", sEndLine = "  ", sColspan = "";

    NamedNodeMap attrs = node.getAttributes();
    if (attrs != null) {
      Node nColSpan = attrs.getNamedItem("colspan");
      Node nAlign = attrs.getNamedItem("align");
      if (nColSpan != null) {
        try {
          int iNbCols = Integer.parseInt(nColSpan.getNodeValue());
          for (int j = 1; j < iNbCols; j++) {
            sColspan += "|";
          }
        }
        catch (NumberFormatException ex) {
          System.err.println("tdProcess => NumberFormatException");
        }
      }
      else {
        if (nAlign != null) {
          String sAlignType = nAlign.getNodeValue();
          if (sAlignType.toUpperCase().equals("RIGHT")) {
            sEndLine = "";
          }
          else if (sAlignType.toUpperCase().equals("LEFT")) {
            sStartLine = "";
          }
        }
      }
    }
    sNode += "|" + sStartLine + getChildrenProcess(node, false, false).trim() +
        sEndLine + sColspan;
    return sNode;
  }

  /**
   * M�thode principale du programme.
   * @param arg Un argument pr�cisant le fichier � traduire.
   */
  public static void main(String[] arg) {
    FileInputStream fis = null;
    try {
      if(arg[0]!=null){
        fis = new FileInputStream(new File(arg[0]));
        String result = HtmlToTwiki.translate(fis);
        System.out.println(result);
      }else{
        System.out.println("HtmlToTwiki : File not found!!");
      }
    }
    catch (FileNotFoundException ex) {
      System.out.println("HtmlToTwiki : File Not Found exception.");
    }
    catch (Exception ex) {
      System.out.println("An error is appeared!!!");
    }
  }
}
