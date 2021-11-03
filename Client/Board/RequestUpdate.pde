
public class requestUpdate extends TimerTask{
  Protocol protocol;
  
  requestUpdate(Protocol activeProtocol) {
    protocol = activeProtocol;
  }
  
  void run() {
    protocol.requestUpdate();
  }
}
