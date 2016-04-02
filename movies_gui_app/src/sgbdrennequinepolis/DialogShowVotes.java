/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package sgbdrennequinepolis;

import java.sql.Array;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Struct;
import java.sql.Timestamp;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;
import oracle.jdbc.OracleTypes;
import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import oracle.sql.StructDescriptor;

/**
 *
 * @author Romain
 */
public class DialogShowVotes extends javax.swing.JDialog
{
    private int _movieId;
    private int _voteNb;
    private int _page;
    /**
     * Creates new form DialogShowVotes
     */
    public DialogShowVotes(java.awt.Frame parent, boolean modal, int movieId, int voteNb)
    {
        super(parent, modal);
        initComponents();
        _movieId = movieId;
        _voteNb = voteNb;
        _page = 1;
        getVotes();
    }
    
    private void getVotes()
    {
        jErrorLabel.setText("");
        try
        {
            // connexion
            LoginSingleton.getInstance().startConnection();
            Object[] data = LoginSingleton.getInstance().showVotesRequest(_movieId, _page);
            
            // lister résultats
            int count = 0;
            Timestamp dateEval;
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
            for(Object tmp : data) 
            {
                count++;
                Struct row = (Struct) tmp;
                
                Object[] values = row.getAttributes();
                dateEval = (Timestamp) values[2];
                switch (count)
                {
                    case 1: jVoteRating1.setText(values[3].toString() + "/10");
                            jVoteUser1.setText("Par " + values[1].toString() + ", le " 
                                    + dateFormat.format(dateEval.getTime()));
                            if (values[4] != null)
                                jVoteReview1.setText(values[4].toString()); 
                            else
                                jVoteReview1.setText("");
                            break;
                    case 2: jVoteRating2.setText(values[3].toString() + "/10");
                            jVoteUser2.setText("Par " + values[1].toString() + ", le " 
                                    + dateFormat.format(dateEval.getTime()));
                            if (values[4] != null)
                                jVoteReview2.setText(values[4].toString()); 
                            else
                                jVoteReview2.setText("");
                            break;
                    case 3: jVoteRating3.setText(values[3].toString() + "/10");
                            jVoteUser3.setText("Par " + values[1].toString() + ", le " 
                                    + dateFormat.format(dateEval.getTime()));
                            if (values[4] != null)
                                jVoteReview3.setText(values[4].toString()); 
                            else
                                jVoteReview3.setText("");
                            break;
                    case 4: jVoteRating4.setText(values[3].toString() + "/10");
                            jVoteUser4.setText("Par " + values[1].toString() + ", le " 
                                    + dateFormat.format(dateEval.getTime()));
                            if (values[4] != null)
                                jVoteReview4.setText(values[4].toString()); 
                            else
                                jVoteReview4.setText("");
                            break;
                    case 5: jVoteRating5.setText(values[3].toString() + "/10");
                            jVoteUser5.setText("Par " + values[1].toString() + ", le " 
                                    + dateFormat.format(dateEval.getTime()));
                            if (values[4] != null)
                                jVoteReview5.setText(values[4].toString()); 
                            else
                                jVoteReview5.setText("");
                            break;
                    default:jVoteRating1.setText(values[3].toString() + "/10");
                            dateEval = (Timestamp) values[2];
                            jVoteUser1.setText("Par " + values[1].toString() + ", le " 
                                    + dateFormat.format(dateEval.getTime()));
                            if (values[4] != null)
                                jVoteReview1.setText(values[4].toString()); 
                            else
                                jVoteReview1.setText("");
                            break;
                }
            }
            
            // vérifier nombre
            if (count < 5)
            {
                jVoteRating5.setText("");
                jVoteUser5.setText("");
                jVoteReview5.setText("");
                if (count < 4)
                {
                    jVoteRating4.setText("");
                    jVoteUser4.setText("");
                    jVoteReview4.setText("");
                    if (count < 3)
                    {
                        jVoteRating3.setText("");
                        jVoteUser3.setText("");
                        jVoteReview3.setText("");
                        if (count < 2)
                        {
                            jVoteRating2.setText("");
                            jVoteUser2.setText("");
                            jVoteReview2.setText("");
                            if (count < 1)
                            {
                                jVoteRating1.setText("");
                                jVoteUser1.setText("");
                                jVoteReview1.setText("");
                            }
                        }
                    }
                }
            }
            // fermeture
            LoginSingleton.getInstance().endCallStatement();
            
        }
        catch(SQLException sqlExc) // ERREUR SQL
        {
            System.out.println("exception SQL : " + sqlExc.getErrorCode());
            if (LoginSingleton.getInstance().checkCrash(sqlExc) == true)
                getVotes();
            else
                jErrorLabel.setText(sqlExc.toString());
        }
        catch(Exception exc)
        {
            jErrorLabel.setText(exc.toString());
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

        jVoteRating1 = new javax.swing.JLabel();
        jPreviousBtn = new javax.swing.JButton();
        jNextBtn = new javax.swing.JButton();
        jVoteUser1 = new javax.swing.JLabel();
        jScrollPane1 = new javax.swing.JScrollPane();
        jVoteReview1 = new javax.swing.JTextArea();
        jVoteRating2 = new javax.swing.JLabel();
        jVoteUser2 = new javax.swing.JLabel();
        jScrollPane2 = new javax.swing.JScrollPane();
        jVoteReview2 = new javax.swing.JTextArea();
        jVoteRating3 = new javax.swing.JLabel();
        jVoteUser3 = new javax.swing.JLabel();
        jScrollPane3 = new javax.swing.JScrollPane();
        jVoteReview3 = new javax.swing.JTextArea();
        jVoteRating4 = new javax.swing.JLabel();
        jVoteUser4 = new javax.swing.JLabel();
        jScrollPane4 = new javax.swing.JScrollPane();
        jVoteReview4 = new javax.swing.JTextArea();
        jVoteRating5 = new javax.swing.JLabel();
        jVoteUser5 = new javax.swing.JLabel();
        jScrollPane5 = new javax.swing.JScrollPane();
        jVoteReview5 = new javax.swing.JTextArea();
        jErrorLabel = new javax.swing.JLabel();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setTitle("Avis des utilisateurs");

        jVoteRating1.setFont(new java.awt.Font("Tahoma", 1, 14)); // NOI18N
        jVoteRating1.setText("- / 10");

        jPreviousBtn.setText("Précédents");
        jPreviousBtn.addActionListener(new java.awt.event.ActionListener()
        {
            public void actionPerformed(java.awt.event.ActionEvent evt)
            {
                jPreviousBtnActionPerformed(evt);
            }
        });

        jNextBtn.setText("Suivants");
        jNextBtn.addActionListener(new java.awt.event.ActionListener()
        {
            public void actionPerformed(java.awt.event.ActionEvent evt)
            {
                jNextBtnActionPerformed(evt);
            }
        });

        jVoteUser1.setText("Par - le -");

        jVoteReview1.setEditable(false);
        jVoteReview1.setColumns(20);
        jVoteReview1.setLineWrap(true);
        jVoteReview1.setRows(5);
        jScrollPane1.setViewportView(jVoteReview1);

        jVoteRating2.setFont(new java.awt.Font("Tahoma", 1, 14)); // NOI18N
        jVoteRating2.setText("- / 10");

        jVoteUser2.setText("Par - le -");

        jVoteReview2.setEditable(false);
        jVoteReview2.setColumns(20);
        jVoteReview2.setLineWrap(true);
        jVoteReview2.setRows(5);
        jScrollPane2.setViewportView(jVoteReview2);

        jVoteRating3.setFont(new java.awt.Font("Tahoma", 1, 14)); // NOI18N
        jVoteRating3.setText("- / 10");

        jVoteUser3.setText("Par - le -");

        jVoteReview3.setEditable(false);
        jVoteReview3.setColumns(20);
        jVoteReview3.setLineWrap(true);
        jVoteReview3.setRows(5);
        jScrollPane3.setViewportView(jVoteReview3);

        jVoteRating4.setFont(new java.awt.Font("Tahoma", 1, 14)); // NOI18N
        jVoteRating4.setText("- / 10");

        jVoteUser4.setText("Par - le -");

        jVoteReview4.setEditable(false);
        jVoteReview4.setColumns(20);
        jVoteReview4.setLineWrap(true);
        jVoteReview4.setRows(5);
        jScrollPane4.setViewportView(jVoteReview4);

        jVoteRating5.setFont(new java.awt.Font("Tahoma", 1, 14)); // NOI18N
        jVoteRating5.setText("- / 10");

        jVoteUser5.setText("Par - le -");

        jVoteReview5.setEditable(false);
        jVoteReview5.setColumns(20);
        jVoteReview5.setLineWrap(true);
        jVoteReview5.setRows(5);
        jScrollPane5.setViewportView(jVoteReview5);

        jErrorLabel.setForeground(new java.awt.Color(204, 0, 51));
        jErrorLabel.setText("-");

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jPreviousBtn, javax.swing.GroupLayout.PREFERRED_SIZE, 100, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jNextBtn, javax.swing.GroupLayout.PREFERRED_SIZE, 100, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(164, 164, 164))
            .addGroup(layout.createSequentialGroup()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addGroup(layout.createSequentialGroup()
                        .addContainerGap()
                        .addComponent(jErrorLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 498, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(javax.swing.GroupLayout.Alignment.LEADING, layout.createSequentialGroup()
                        .addGap(23, 23, 23)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                            .addGroup(layout.createSequentialGroup()
                                .addComponent(jVoteRating5)
                                .addGap(18, 18, 18)
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                    .addComponent(jScrollPane5, javax.swing.GroupLayout.PREFERRED_SIZE, 440, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(jVoteUser5, javax.swing.GroupLayout.PREFERRED_SIZE, 440, javax.swing.GroupLayout.PREFERRED_SIZE)))
                            .addGroup(layout.createSequentialGroup()
                                .addComponent(jVoteRating4)
                                .addGap(18, 18, 18)
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                    .addComponent(jScrollPane4, javax.swing.GroupLayout.PREFERRED_SIZE, 440, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(jVoteUser4, javax.swing.GroupLayout.PREFERRED_SIZE, 440, javax.swing.GroupLayout.PREFERRED_SIZE)))
                            .addGroup(layout.createSequentialGroup()
                                .addComponent(jVoteRating3)
                                .addGap(18, 18, 18)
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                    .addComponent(jScrollPane3, javax.swing.GroupLayout.PREFERRED_SIZE, 440, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(jVoteUser3, javax.swing.GroupLayout.PREFERRED_SIZE, 440, javax.swing.GroupLayout.PREFERRED_SIZE)))
                            .addGroup(layout.createSequentialGroup()
                                .addComponent(jVoteRating2)
                                .addGap(18, 18, 18)
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                    .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 440, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(jVoteUser2, javax.swing.GroupLayout.PREFERRED_SIZE, 440, javax.swing.GroupLayout.PREFERRED_SIZE)))
                            .addGroup(layout.createSequentialGroup()
                                .addComponent(jVoteRating1)
                                .addGap(18, 18, 18)
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                    .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 440, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(jVoteUser1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))))
                .addContainerGap(19, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(5, 5, 5)
                .addComponent(jErrorLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 19, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jVoteRating1)
                    .addComponent(jVoteUser1))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 43, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jVoteRating2)
                    .addComponent(jVoteUser2))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 43, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jVoteRating3)
                    .addComponent(jVoteUser3))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane3, javax.swing.GroupLayout.PREFERRED_SIZE, 43, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jVoteRating4)
                    .addComponent(jVoteUser4))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane4, javax.swing.GroupLayout.PREFERRED_SIZE, 43, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jVoteRating5)
                    .addComponent(jVoteUser5))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane5, javax.swing.GroupLayout.PREFERRED_SIZE, 43, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 22, Short.MAX_VALUE)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jPreviousBtn)
                    .addComponent(jNextBtn))
                .addGap(21, 21, 21))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void jPreviousBtnActionPerformed(java.awt.event.ActionEvent evt)//GEN-FIRST:event_jPreviousBtnActionPerformed
    {//GEN-HEADEREND:event_jPreviousBtnActionPerformed
        // TODO add your handling code here:
        _page -= 1;
        if (_page < 1)
            _page = (_voteNb + 4)/5;
        getVotes();
    }//GEN-LAST:event_jPreviousBtnActionPerformed

    private void jNextBtnActionPerformed(java.awt.event.ActionEvent evt)//GEN-FIRST:event_jNextBtnActionPerformed
    {//GEN-HEADEREND:event_jNextBtnActionPerformed
        // TODO add your handling code here:
        _page += 1;
        if (_page > (_voteNb + 4)/5)
            _page = 1;
        getVotes();
    }//GEN-LAST:event_jNextBtnActionPerformed



    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JLabel jErrorLabel;
    private javax.swing.JButton jNextBtn;
    private javax.swing.JButton jPreviousBtn;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JScrollPane jScrollPane4;
    private javax.swing.JScrollPane jScrollPane5;
    private javax.swing.JLabel jVoteRating1;
    private javax.swing.JLabel jVoteRating2;
    private javax.swing.JLabel jVoteRating3;
    private javax.swing.JLabel jVoteRating4;
    private javax.swing.JLabel jVoteRating5;
    private javax.swing.JTextArea jVoteReview1;
    private javax.swing.JTextArea jVoteReview2;
    private javax.swing.JTextArea jVoteReview3;
    private javax.swing.JTextArea jVoteReview4;
    private javax.swing.JTextArea jVoteReview5;
    private javax.swing.JLabel jVoteUser1;
    private javax.swing.JLabel jVoteUser2;
    private javax.swing.JLabel jVoteUser3;
    private javax.swing.JLabel jVoteUser4;
    private javax.swing.JLabel jVoteUser5;
    // End of variables declaration//GEN-END:variables
}
