public class RequestUpdate implements Runnable{
  Protocol protocol;
  
  /**
  *  Constructor for RequestUpdate
  *  @param activeProtocol  protocol object which Listen() should be run from
  */
  RequestUpdate(Protocol activeProtocol) {
    protocol = activeProtocol;
  }
  
  /**
  *  Function meant to be multithreaded as to allow client to listen for data and manage local state/display at the same time
  */
  void run() {
    protocol.Connect();
    while(!protocol.socket.isClosed()) {
      protocol.Listen();
    }
  }
}
