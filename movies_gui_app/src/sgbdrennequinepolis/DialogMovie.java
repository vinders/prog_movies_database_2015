/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package sgbdrennequinepolis;

import java.net.URL;
import java.sql.Array;
import java.sql.Struct;
import javax.swing.ImageIcon;

/**
 *
 * @author Romain
 */
public class DialogMovie extends javax.swing.JDialog
{
    private int _movieId = -1;
    private int _voteNb = -1;
    /**
     * Creates new form DialogMovie
     */
    // AFFICHAGE D'INFORMATIONS DU FILM
    public DialogMovie(java.awt.Frame parent, boolean modal, Struct data)
    {
        super(parent, modal);
        initComponents();
               
        // afficher données
        try
        {
            Object[] values = data.getAttributes();
            String tmpVal = values[0].toString();
            _movieId = Integer.parseInt(tmpVal);
            
            // titre et année
            if (values[3] == null)
                jMovieTitle.setText(values[1].toString());
            else
            {
                tmpVal = values[3].toString();
                jMovieTitle.setText(values[1].toString() + " (" + tmpVal + ")");
            }
            // titre original
            if (!(values[1].toString().equals((String)values[2])))
                jMovieOrigTitle.setText("(titre original : " + values[2].toString() + ")");
            else
                jMovieOrigTitle.setText("");
            
            // cotations
            jTMDBavg.setText(values[4].toString() + "/10");
            jTMDBnb.setText("(" + values[5].toString() + " votes)");
            if (values[7].toString().equals("0"))
                jRQSavg.setText("-/10");
            else
                jRQSavg.setText(values[6].toString() + "/10");
            jRQSnb.setText("(" + values[7].toString() + " votes)");
            if (values[7] != null)
                _voteNb = Integer.parseInt(values[7].toString());
            else
                _voteNb = 0;

            // durée
            if (values[8] != null)
            {
                tmpVal = values[8].toString();
                int runtime = Integer.parseInt(tmpVal);
                jRuntime.setText("Durée : " + runtime/60 + "h " + runtime%60);
            }
            else
                jRuntime.setText("");
            // statut + certification
            if (values[14] != null)
                jStatus.setText(values[13].toString() + ", " + values[14].toString());
            else
                jStatus.setText(values[13].toString());
    
            
            
            // recettes/dépenses
            if (values[10] != null)
            {
                if (values[11] != null)
                {
                    jMoney.setText("Recettes/budget : " + values[11].toString() + " / " + values[10].toString());
                }
                else
                {
                    jMoney.setText("Budget : " + values[10].toString());
                }
            }
            else
            {
                if (values[11] != null)
                {
                    jMoney.setText("Recettes : " + values[11].toString());
                }
            }
            
            // résumé
            if (values[12] != null)
                jOverview.setText((String)values[12]);   

            try
            {
                // informations listées
                String rowList;
                Object[] genres = (Object[]) ((Array) values[15]).getArray();
                rowList = "Genre(s) : " + (String) genres[0];
                for (int i = 1; i < genres.length; i++) 
                {
                    rowList += ", " + (String) genres[i];
                }
                jGenres.setText(rowList);
                Object[] actors = (Object[]) ((Array) values[16]).getArray();
                Object[] characters = (Object[]) ((Array) values[17]).getArray();
                rowList = "Acteurs : " + (String) actors[0] + " (" + characters[0] + ")";
                for (int i = 1; i < actors.length && i < characters.length; i++) 
                {
                    rowList += ", " + (String) actors[i] + " (" + (String) characters[i] + ")";
                }
                jActors.setText(rowList);
                Object[] directors = (Object[]) ((Array) values[18]).getArray();
                rowList = "Directeur(s) : " + (String) directors[0];
                for (int i = 1; i < directors.length; i++) 
                {
                    rowList += ", " + (String) directors[i];
                }
                jDirectors.setText(rowList);
                Object[] prodcomps = (Object[]) ((Array) values[19]).getArray();
                rowList = "Producteur(s) : " + (String) prodcomps[0];
                for (int i = 1; i < prodcomps.length; i++) 
                {
                    rowList += ", " + (String) prodcomps[i];
                }
                jProdcomps.setText(rowList);
                Object[] countries = (Object[]) ((Array) values[20]).getArray();
                rowList = "Pays : " + (String) countries[0];
                for (int i = 1; i < countries.length; i++) 
                {
                    rowList += ", " + (String) countries[i];
                }
                jCountries.setText(rowList);
                Object[] languages = (Object[]) ((Array) values[21]).getArray();
                rowList = "Langue(s) : " + (String) languages[0];
                for (int i = 1; i < languages.length; i++) 
                {
                    rowList += ", " + (String) languages[i];
                }
                jLanguages.setText(rowList);
            }
            catch(Exception exc)
            {
                jErrorLabel.setText("Erreur de récupération des données de listes...");
            }
                    
            try
            {
                // image
                if (values[9] != null)
                {
                    jPictureBox.setIcon(new ImageIcon(new URL("http://image.tmdb.org/t/p/w185" + (String)values[9])));
                }
            }
            catch(Exception exc)
            {
                jErrorLabel.setText("Image indisponible...");
            } 
        }
        catch(Exception exc)
        {
            jErrorLabel.setText("Erreur de récupération des données...");
        }
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents()
    {

        jErrorLabel = new javax.swing.JLabel();
        jLabel1 = new javax.swing.JLabel();
        jMovieTitle = new javax.swing.JLabel();
        jPictureBox = new javax.swing.JLabel();
        jMovieOrigTitle = new javax.swing.JLabel();
        jLabel2 = new javax.swing.JLabel();
        jLabel3 = new javax.swing.JLabel();
        jTMDBavg = new javax.swing.JLabel();
        jRQSavg = new javax.swing.JLabel();
        jTMDBnb = new javax.swing.JLabel();
        jRQSnb = new javax.swing.JLabel();
        jRuntime = new javax.swing.JLabel();
        jStatus = new javax.swing.JLabel();
        jMoney = new javax.swing.JLabel();
        jScrollPane1 = new javax.swing.JScrollPane();
        jOverview = new javax.swing.JTextArea();
        jScrollPane2 = new javax.swing.JScrollPane();
        jActors = new javax.swing.JTextArea();
        jScrollPane3 = new javax.swing.JScrollPane();
        jCountries = new javax.swing.JTextArea();
        jScrollPane4 = new javax.swing.JScrollPane();
        jDirectors = new javax.swing.JTextArea();
        jScrollPane5 = new javax.swing.JScrollPane();
        jLanguages = new javax.swing.JTextArea();
        jScrollPane6 = new javax.swing.JScrollPane();
        jProdcomps = new javax.swing.JTextArea();
        jGenres = new javax.swing.JLabel();
        jBtnShowVotes = new javax.swing.JButton();
        jBtnWriteVote = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setTitle("Fiche de film");

        jErrorLabel.setForeground(new java.awt.Color(204, 0, 51));
        jErrorLabel.setText("-");

        jLabel1.setFont(new java.awt.Font("Tahoma", 1, 12)); // NOI18N
        jLabel1.setText("Fiche du film :");

        jMovieTitle.setText("-");

        jPictureBox.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(204, 204, 255)));
        jPictureBox.setOpaque(true);

        jMovieOrigTitle.setText("-");

        jLabel2.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        jLabel2.setText("TMDB : ");

        jLabel3.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        jLabel3.setText("RQS :");

        jTMDBavg.setFont(new java.awt.Font("Tahoma", 1, 14)); // NOI18N
        jTMDBavg.setText("--/10");

        jRQSavg.setFont(new java.awt.Font("Tahoma", 1, 14)); // NOI18N
        jRQSavg.setText("--/10");

        jTMDBnb.setText("(- votes)");

        jRQSnb.setText("(- votes)");

        jRuntime.setText("Durée : -");

        jStatus.setText("-");

        jMoney.setText("Recettes : -");

        jScrollPane1.setAutoscrolls(true);
        jScrollPane1.setFocusable(false);
        jScrollPane1.setOpaque(false);

        jOverview.setEditable(false);
        jOverview.setColumns(20);
        jOverview.setFont(new java.awt.Font("Arial", 0, 11)); // NOI18N
        jOverview.setLineWrap(true);
        jOverview.setRows(5);
        jOverview.setBorder(null);
        jScrollPane1.setViewportView(jOverview);

        jActors.setEditable(false);
        jActors.setColumns(20);
        jActors.setFont(new java.awt.Font("Arial", 0, 11)); // NOI18N
        jActors.setLineWrap(true);
        jActors.setRows(5);
        jScrollPane2.setViewportView(jActors);

        jCountries.setEditable(false);
        jCountries.setColumns(20);
        jCountries.setFont(new java.awt.Font("Arial", 0, 11)); // NOI18N
        jCountries.setLineWrap(true);
        jCountries.setRows(5);
        jScrollPane3.setViewportView(jCountries);

        jDirectors.setEditable(false);
        jDirectors.setColumns(20);
        jDirectors.setFont(new java.awt.Font("Arial", 0, 11)); // NOI18N
        jDirectors.setLineWrap(true);
        jDirectors.setRows(5);
        jScrollPane4.setViewportView(jDirectors);

        jLanguages.setEditable(false);
        jLanguages.setColumns(20);
        jLanguages.setFont(new java.awt.Font("Arial", 0, 11)); // NOI18N
        jLanguages.setLineWrap(true);
        jLanguages.setRows(5);
        jScrollPane5.setViewportView(jLanguages);

        jProdcomps.setEditable(false);
        jProdcomps.setColumns(20);
        jProdcomps.setFont(new java.awt.Font("Arial", 0, 11)); // NOI18N
        jProdcomps.setLineWrap(true);
        jProdcomps.setRows(5);
        jScrollPane6.setViewportView(jProdcomps);

        jGenres.setText("Genres : -");

        jBtnShowVotes.setText("Voir les avis");
        jBtnShowVotes.addActionListener(new java.awt.event.ActionListener()
        {
            public void actionPerformed(java.awt.event.ActionEvent evt)
            {
                jBtnShowVotesActionPerformed(evt);
            }
        });

        jBtnWriteVote.setText("Rédiger un avis");
        jBtnWriteVote.addActionListener(new java.awt.event.ActionListener()
        {
            public void actionPerformed(java.awt.event.ActionEvent evt)
            {
                jBtnWriteVoteActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(19, 19, 19)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(jLabel1)
                        .addGap(18, 18, 18)
                        .addComponent(jMovieTitle, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                    .addComponent(jErrorLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addGroup(layout.createSequentialGroup()
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jPictureBox, javax.swing.GroupLayout.PREFERRED_SIZE, 185, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                                .addComponent(jBtnWriteVote, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 143, Short.MAX_VALUE)
                                .addComponent(jBtnShowVotes, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jMovieOrigTitle, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addGroup(layout.createSequentialGroup()
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addGroup(layout.createSequentialGroup()
                                        .addComponent(jLabel2)
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                        .addComponent(jTMDBavg)
                                        .addGap(18, 18, 18)
                                        .addComponent(jTMDBnb))
                                    .addGroup(layout.createSequentialGroup()
                                        .addComponent(jLabel3)
                                        .addGap(18, 18, 18)
                                        .addComponent(jRQSavg)
                                        .addGap(18, 18, 18)
                                        .addComponent(jRQSnb)))
                                .addGap(84, 84, 84)
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addGroup(layout.createSequentialGroup()
                                        .addComponent(jMoney)
                                        .addGap(0, 0, Short.MAX_VALUE))
                                    .addComponent(jStatus, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                    .addComponent(jRuntime, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
                            .addComponent(jScrollPane1)
                            .addComponent(jScrollPane2)
                            .addGroup(layout.createSequentialGroup()
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                                    .addComponent(jScrollPane3, javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(jScrollPane4, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.PREFERRED_SIZE, 226, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 14, Short.MAX_VALUE)
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                    .addComponent(jScrollPane6)
                                    .addComponent(jScrollPane5, javax.swing.GroupLayout.PREFERRED_SIZE, 230, javax.swing.GroupLayout.PREFERRED_SIZE)))
                            .addComponent(jGenres, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel1)
                    .addComponent(jMovieTitle))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(jPictureBox, javax.swing.GroupLayout.PREFERRED_SIZE, 278, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(jBtnShowVotes)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jBtnWriteVote))
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(jMovieOrigTitle, javax.swing.GroupLayout.PREFERRED_SIZE, 19, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(jLabel2)
                            .addComponent(jTMDBavg)
                            .addComponent(jTMDBnb)
                            .addComponent(jRuntime))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(jLabel3)
                            .addComponent(jRQSavg)
                            .addComponent(jRQSnb)
                            .addComponent(jStatus))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jMoney)
                        .addGap(13, 13, 13)
                        .addComponent(jGenres)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 61, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 62, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(jScrollPane4, javax.swing.GroupLayout.PREFERRED_SIZE, 0, Short.MAX_VALUE)
                            .addComponent(jScrollPane6, javax.swing.GroupLayout.PREFERRED_SIZE, 44, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(jScrollPane3, javax.swing.GroupLayout.PREFERRED_SIZE, 0, Short.MAX_VALUE)
                            .addComponent(jScrollPane5, javax.swing.GroupLayout.PREFERRED_SIZE, 43, javax.swing.GroupLayout.PREFERRED_SIZE))))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 16, Short.MAX_VALUE)
                .addComponent(jErrorLabel)
                .addContainerGap())
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    // OUVERTURE LISTE DE VOTES
    private void jBtnShowVotesActionPerformed(java.awt.event.ActionEvent evt)//GEN-FIRST:event_jBtnShowVotesActionPerformed
    {//GEN-HEADEREND:event_jBtnShowVotesActionPerformed
        // TODO add your handling code here:
        if (_movieId > -1)
        {
            DialogShowVotes dialog = new DialogShowVotes(new javax.swing.JFrame(), true, _movieId, _voteNb);
            dialog.setVisible(true);
        }
    }//GEN-LAST:event_jBtnShowVotesActionPerformed

    // OUVERTURE FENETRE POUR VOTER
    private void jBtnWriteVoteActionPerformed(java.awt.event.ActionEvent evt)//GEN-FIRST:event_jBtnWriteVoteActionPerformed
    {//GEN-HEADEREND:event_jBtnWriteVoteActionPerformed
        // Identification
        LoginSingleton login = LoginSingleton.getInstance();
        if (login.getLogin() == null)
        {
            DialogLogin dialogLogin = new DialogLogin(new javax.swing.JFrame(), true);
            dialogLogin.setVisible(true);
            if (dialogLogin.getLogin() == null)
                return;
            login.setLogin(dialogLogin.getLogin());
        }
        
        // Vote
        DialogWriteVote dialog = new DialogWriteVote(new javax.swing.JFrame(), true, _movieId);
        dialog.setVisible(true);
    }//GEN-LAST:event_jBtnWriteVoteActionPerformed

    /**
     * @param args the command line arguments
     */

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JTextArea jActors;
    private javax.swing.JButton jBtnShowVotes;
    private javax.swing.JButton jBtnWriteVote;
    private javax.swing.JTextArea jCountries;
    private javax.swing.JTextArea jDirectors;
    private javax.swing.JLabel jErrorLabel;
    private javax.swing.JLabel jGenres;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JTextArea jLanguages;
    private javax.swing.JLabel jMoney;
    private javax.swing.JLabel jMovieOrigTitle;
    private javax.swing.JLabel jMovieTitle;
    private javax.swing.JTextArea jOverview;
    private javax.swing.JLabel jPictureBox;
    private javax.swing.JTextArea jProdcomps;
    private javax.swing.JLabel jRQSavg;
    private javax.swing.JLabel jRQSnb;
    private javax.swing.JLabel jRuntime;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JScrollPane jScrollPane4;
    private javax.swing.JScrollPane jScrollPane5;
    private javax.swing.JScrollPane jScrollPane6;
    private javax.swing.JLabel jStatus;
    private javax.swing.JLabel jTMDBavg;
    private javax.swing.JLabel jTMDBnb;
    // End of variables declaration//GEN-END:variables
}
