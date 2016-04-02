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
import java.sql.Types;
import java.util.HashMap;
import oracle.jdbc.OracleTypes;
import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import oracle.sql.StructDescriptor;

/**
 *
 * @author Romain
 */
public class LoginSingleton
{
    // instance
    private static LoginSingleton _instance = null;
    // var membres
    private String _login = null;
    private boolean _secondaryServer = false;
    private Connection _connex = null;
    private CallableStatement _callStatement = null;

    private LoginSingleton()
    {
    }
    // INSTANCIATION
    public static LoginSingleton getInstance()
    {
        if (_instance == null)
            _instance = new LoginSingleton();
        return _instance;
    }
    
    // getters / setters
    public void setLogin(String login)
    {   
        _login = login;
    }
    public String getLogin()
    {
        return _login;
    }
    public void setSecondaryServer(boolean secondaryServer)
    {
        this._secondaryServer = secondaryServer;
    }
    public boolean getSecondaryServer()
    {
        return this._secondaryServer;
    }
    public Connection getConnex()
    {
        return _connex;
    }
    public void setConnex(Connection connex)
    {
        if (connex == null)
        {
            try
            {
                this._connex.close();
            }
            catch (Exception exc) {}
        }
        this._connex = connex;
    }
    public CallableStatement getCallStatement()
    {
        return _callStatement;
    }
    public void setCallStatement(CallableStatement callStatement)
    {
        this._callStatement = callStatement;
    }
    public void endCallStatement()
    {
        try
        {
            this._callStatement.close();
        }
        catch(Exception exc) {}
        this._callStatement = null;
    }
    
    // CONNEXION CB/CBB
    public void startConnection() throws Exception
    {
        if (getConnex() == null || getConnex().isValid(2) == false) // connexion inexistante ou expirée
        {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            if (getSecondaryServer() == false)
            {
                System.out.println("connexion CB");
                setConnex(DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","CB","dummy"));
            }
            else
            {
                System.out.println("connexion CBB");
                setConnex(DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","CBB","dummy"));
            }
        }
    }
    // GESTION DE CRASH CB/CBB
    public boolean checkCrash(SQLException exc)
    {
        if (getSecondaryServer() == false && exc.getErrorCode() == 28000) // CB + exception base de données inaccessible
        {
            System.out.println("crash CB");
            setSecondaryServer(true);
            setConnex(null);
            return true;
        }
        else if (getSecondaryServer() == true && exc.getErrorCode() == 20400) // CBB + exception personnalisée (CB de retour)
        {
            System.out.println("crash CBB");
            setSecondaryServer(false);
            setConnex(null);
            return true;
        }
        return false;
    }
    
    // REQUETE - recherche de films
    public ResultSet findMoviesRequest(String title, String year, String yearMin, String yearMax, 
                                  HashMap<String,String> actors, HashMap<String,String> directors) throws Exception
    {
        String sqlQuery = null;

        // types personnalisés
        final String typeArray = "STRINGARRAY_T";
        ArrayDescriptor arrayDescriptor = ArrayDescriptor.createDescriptor(typeArray.toUpperCase(), getConnex());

        // lecture données
        String[] actorsArray = new String[actors.size()]; 
        int idx = 0;
        for (Object tmp : actors.values())
        {
            actorsArray[idx] = (String) tmp;
            idx++;
        }
        ARRAY actorsObjects = new ARRAY(
            arrayDescriptor, 
            getConnex(), 
            actorsArray
        );
        String[] directorsArray = new String[directors.size()]; 
        idx = 0;
        for (Object tmp : directors.values())
        {
            directorsArray[idx] = (String) tmp;
            idx++;
        }
        ARRAY directorsObjects = new ARRAY(
            arrayDescriptor, 
            getConnex(), 
            directorsArray
        );

        // requête
        sqlQuery = "{call SEARCH_PACKAGE.FindMovies(?,?,?,?,?,?,?,?,?)}";
        setCallStatement(getConnex().prepareCall(sqlQuery));
        getCallStatement().setString(1, title);
        getCallStatement().setString(2, year);
        getCallStatement().setString(3, yearMin);
        getCallStatement().setString(4, yearMax);
        getCallStatement().setInt(5, actors.size());
        getCallStatement().setObject(6, actorsObjects, Types.ARRAY);
        getCallStatement().setInt(7, directors.size());
        getCallStatement().setObject(8, directorsObjects, Types.ARRAY);
        getCallStatement().registerOutParameter(9, OracleTypes.CURSOR);	
        getCallStatement().execute();
        return (ResultSet)getCallStatement().getObject(9);
    }
    // REQUETE - obtention des informations d'un film
    public Struct getMovieRequest(Integer idMovie) throws Exception
    {
        String sqlQuery = null;

        // types personnalisés
        final String typeName = "MOVIEOBJ_T";
        final String typeTableName = "STRINGARRAY_T";
        StructDescriptor structDescriptor = StructDescriptor.createDescriptor(typeName.toUpperCase(), getConnex());		
        ResultSetMetaData metaData = structDescriptor.getMetaData();       

        // requête
        sqlQuery = "{call SEARCH_PACKAGE.GetMovieById(?,?)}";
        setCallStatement(getConnex().prepareCall(sqlQuery));
        getCallStatement().setInt(1, idMovie);
        getCallStatement().registerOutParameter(2, Types.STRUCT, typeName);
        getCallStatement().execute();
        Struct data = (Struct)getCallStatement().getObject(2);
        endCallStatement();
        return data;
    }
    // REQUETE - envoi de vote
    public void writeVoteRequest(Integer movieId, Integer vote, String review) throws Exception
    {
        String sqlQuery = null;

        // requête
        sqlQuery = "{call EVAL_PACKAGE.AddUserReview(?,?,?,?)}";
        setCallStatement(getConnex().prepareCall(sqlQuery));
        getCallStatement().setString(1, getLogin());
        getCallStatement().setInt(2, movieId);
        getCallStatement().setInt(3, vote);
        getCallStatement().setString(4, review);
        getCallStatement().execute();
        endCallStatement();
    }
    // REQUETE - liste des votes
    public Object[] showVotesRequest(int movieId, int page) throws Exception
    {
        String sqlQuery = null;

        // types personnalisés
        final String typeName = "VOTELISTITEM_T";
        final String typeTableName = "VOTESLIST_T";
        StructDescriptor structDescriptor = StructDescriptor.createDescriptor(typeName.toUpperCase(), getConnex());		
        ResultSetMetaData metaData = structDescriptor.getMetaData();


        // requête
        sqlQuery = "{call SEARCH_PACKAGE.GetVotes(?,?,?)}";
        setCallStatement(getConnex().prepareCall(sqlQuery));
        getCallStatement().setInt(1, movieId);
        getCallStatement().setInt(2, page);
        getCallStatement().registerOutParameter(3, Types.ARRAY, typeTableName);	
        getCallStatement().execute();

        // lister résultats
        return (Object[]) ((Array) getCallStatement().getObject(3)).getArray();
    }
}
