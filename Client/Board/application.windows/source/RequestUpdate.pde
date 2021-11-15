
public class RequestUpdate implements Runnable{
  Protocol protocol;
  
  RequestUpdate(Protocol activeProtocol) {
    protocol = activeProtocol;
  }
  
  void run() {
    while(!protocol.socket.isClosed()) {
      protocol.Listen();
    }
  }
}
