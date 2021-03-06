//clase usuario
public class Usuario {
  //Todos los usuarios del sistema tendrán estos atributos.
  String Nombre; //Es el nombre de la persona, se usa para terminos de claridad y de entendimiento de los usuarios.
  String CardID;  //Es el ID del carnet, nos permite la autenticación del usuario.
  boolean Estado; //Es un booleano que nos permite saber si el usuario esta activo: true (usandouna bici) o inactivo: false (ya ha devuelto la bici)
  String Correo;
  //Se crea un primer constructor del objeto, este constructor se usa para cuando el usuario no se ha registrado

  public Usuario(String Nombre, String CardID, String Correo, MySQL msql) {//usuario no registrado                         
    this.Nombre = Nombre;                                                                                 
    this.CardID = CardID;                                                                                 
    this.Estado = false;   
    this.Correo = Correo;
    msql.execute("INSERT INTO usuarios (CardIDUsuario,NombreUsuario,CorreoUsuario,EstadoUsuario) values ('"+CardID+"','"+Nombre+"','"+Correo+"',false)");
  }                                                                                                       

  //Se crea un segundo constructor, el cual se usa para un usuario registrado, este constructor solo recibe dos parametros
  public Usuario(String CardID, MySQL msql) {//usuario registrado                                           
    msql.query("SELECT NombreUsuario, EstadoUsuario, CorreoUsuario FROM usuarios WHERE CardIDUsuario LIKE '"+CardID+"%'");                     
    msql.next();                                                                                          
    this.Nombre = msql.getString(1);                                                                      
    this.CardID = CardID;                                   
    this.Estado = msql.getBoolean(2);
    this.Correo = msql.getString(3);
  }  
  void accion() {//Funcion para saber si el usuario pide o devuelve la bici
    msql.query("SELECT EstadoUsuario FROM usuarios WHERE CardIDUsuario LIKE'"+this.CardID+"%'");
    msql.next();
    this.Estado = msql.getBoolean(1);
    if (this.Estado == false) {
      msql.query("SELECT COUNT(*) FROM deudores WHERE CardIDUsuario LIKE'"+this.CardID+"%'");
      msql.next();
      if (msql.getInt(1)==0) {
        msql.query("SELECT COUNT(*) FROM `estaciones`,`estación-bicicletas`,`bicicletas` WHERE (`estación-bicicletas`.`IdEstacion` = `estaciones`.`IdEstacion`) AND (`estación-bicicletas`.`IdBicicletas`=`bicicletas`.`IdBicicleta`) AND (`estaciones`.`NombreEstacion`='"+CurrentStation+"')");
        msql.next();
        if (msql.getInt(1) == 0) {
          println("No hay bicicletas disponibles");
        } else {         
          bici = new Bicicleta(msql);
          println(bici.Number);
          bici.assignBike();
          mode++;
        }
      } else {
        msql.query("SELECT ValorMulta FROM deudores WHERE CardIDUsuario LIKE'"+this.CardID+"%'");
        int Valor_Multa = msql.getInt(1);
        println("No puedes pedir una bici, debes pagar un valor de $"+Valor_Multa);
      }
    } else {
      bici = new Bicicleta(msql);
      bici.returnBike();
      //int confirm = Dialogo.confirmar("Devolver Bicicleta","¿Desea devolver la bicicleta?",Dialogo.TIPO_ERROR,Dialogo.OPCION_OK_CANCELAR);
      //println(confirm);
      mode++;
    }
  }
}