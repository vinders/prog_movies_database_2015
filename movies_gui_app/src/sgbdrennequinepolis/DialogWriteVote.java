/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package sgbdrennequinepolis;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;
import oracle.jdbc.OracleTypes;
import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import oracle.sql.StructDescriptor;

/**
 *
 * @author Romain
 */
public class DialogWriteVote extends javax.swing.JDialog
{
    private int _movieId = -1;
    /**
     * Creates new form DialogWriteVote
     */
    public DialogWriteVote(java.awt.Frame parent, boolean modal, int movieId)
    {
        super(parent, modal);
        initComponents();
        _movieId = movieId;
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

        jScrollPane1 = new javax.swing.JScrollPane();
        jReviewBox = new javax.swing.JTextArea();
        jVoteSlider = new javax.swing.JSlider();
        jVoteLabel = new javax.swing.JLabel();
        jConfirmBtn = new javax.swing.JButton();
        jCancelBtn = new javax.swing.JButton();
        jErrorLabel = new javax.swing.JLabel();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setTitle("Ajouter un avis...");

        jReviewBox.setColumns(20);
        jReviewBox.setLineWrap(true);
        jReviewBox.setRows(5);
        jScrollPane1.setViewportView(jReviewBox);

        jVoteSlider.setMajorTickSpacing(1);
        jVoteSlider.setMaximum(10);
        jVoteSlider.setMinorTickSpacing(1);
        jVoteSlider.setPaintTicks(true);
        jVoteSlider.setValue(5);
        jVoteSlider.addMouseListener(new java.awt.event.MouseAdapter()
        {
            public void mouseReleased(java.awt.event.MouseEvent evt)
            {
                jVoteSliderMouseReleased(evt);
            }
        });
        jVoteSlider.addInputMethodListener(new java.awt.event.InputMethodListener()
        {
            public void caretPositionChanged(java.awt.event.InputMethodEvent evt)
            {
                jVoteSliderCaretPositionChanged(evt);
            }
            public void inputMethodTextChanged(java.awt.event.InputMethodEvent evt)
            {
            }
        });

        jVoteLabel.setFont(new java.awt.Font("Arial", 1, 14)); // NOI18N
        jVoteLabel.setText("5/10");

        jConfirmBtn.setText("Envoyer");
        jConfirmBtn.addActionListener(new java.awt.event.ActionListener()
        {
            public void actionPerformed(java.awt.event.ActionEvent evt)
            {
                jConfirmBtnActionPerformed(evt);
            }
        });

        jCancelBtn.setText("Annuler");
        jCancelBtn.addActionListener(new java.awt.event.ActionListener()
        {
            public void actionPerformed(java.awt.event.ActionEvent evt)
            {
                jCancelBtnActionPerformed(evt);
            }
        });

        jErrorLabel.setForeground(new java.awt.Color(204, 0, 51));
        jErrorLabel.setText("-");

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(33, 33, 33)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(jScrollPane1)
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(jVoteSlider, javax.swing.GroupLayout.PREFERRED_SIZE, 250, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(jVoteLabel, javax.swing.GroupLayout.DEFAULT_SIZE, 56, Short.MAX_VALUE))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                        .addComponent(jConfirmBtn, javax.swing.GroupLayout.PREFERRED_SIZE, 116, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jCancelBtn, javax.swing.GroupLayout.PREFERRED_SIZE, 101, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(jErrorLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                .addContainerGap(35, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(32, 32, 32)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jVoteSlider, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jVoteLabel))
                .addGap(18, 18, 18)
                .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jConfirmBtn)
                    .addComponent(jCancelBtn))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jErrorLabel)
                .addContainerGap())
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void jVoteSliderCaretPositionChanged(java.awt.event.InputMethodEvent evt)//GEN-FIRST:event_jVoteSliderCaretPositionChanged
    {//GEN-HEADEREND:event_jVoteSliderCaretPositionChanged
        jVoteLabel.setText(jVoteSlider.getValue()+"/10");
    }//GEN-LAST:event_jVoteSliderCaretPositionChanged

    private void jConfirmBtnActionPerformed(java.awt.event.ActionEvent evt)//GEN-FIRST:event_jConfirmBtnActionPerformed
    {//GEN-HEADEREND:event_jConfirmBtnActionPerformed
        if (jReviewBox.getText().length() > 200)
        {
            javax.swing.JOptionPane.showMessageDialog(this, "Votre message dépasse le maximum de 200 caractères.");
            return;
        }
        
        try
        {
            // connexion
            LoginSingleton.getInstance().startConnection();
            // requête
            LoginSingleton.getInstance().writeVoteRequest(_movieId, jVoteSlider.getValue(), jReviewBox.getText());
            setVisible(false);
            return;
        }
        catch(SQLException sqlExc) // ERREUR SQL
        {
            System.out.println("exception SQL : " + sqlExc.getErrorCode());
            if (LoginSingleton.getInstance().checkCrash(sqlExc) == true)
                jConfirmBtnActionPerformed(evt);
            else
                jErrorLabel.setText(sqlExc.toString());
        }
        catch(Exception exc)
        {
            jErrorLabel.setText(exc.toString());
        }
    }//GEN-LAST:event_jConfirmBtnActionPerformed

    private void jCancelBtnActionPerformed(java.awt.event.ActionEvent evt)//GEN-FIRST:event_jCancelBtnActionPerformed
    {//GEN-HEADEREND:event_jCancelBtnActionPerformed
        setVisible(false);
    }//GEN-LAST:event_jCancelBtnActionPerformed

    private void jVoteSliderMouseReleased(java.awt.event.MouseEvent evt)//GEN-FIRST:event_jVoteSliderMouseReleased
    {//GEN-HEADEREND:event_jVoteSliderMouseReleased
        jVoteLabel.setText(jVoteSlider.getValue()+"/10");
    }//GEN-LAST:event_jVoteSliderMouseReleased



    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton jCancelBtn;
    private javax.swing.JButton jConfirmBtn;
    private javax.swing.JLabel jErrorLabel;
    private javax.swing.JTextArea jReviewBox;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JLabel jVoteLabel;
    private javax.swing.JSlider jVoteSlider;
    // End of variables declaration//GEN-END:variables
}