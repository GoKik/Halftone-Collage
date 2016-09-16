public class Action<T> {
  
  private OnChangeListener listener;
  private T valOld, valNew;
  
  public Action(T vold, T vnew, OnChangeListener l) {
    valOld = vold;
    valNew = vnew;
    listener = l;
    hPos = 0;
  }
  
  public void back() {
    T temp = valOld;
    valOld = valNew;
    valNew = temp;
    listener.onChange(temp);
    listener.onRender(false);
  }

}