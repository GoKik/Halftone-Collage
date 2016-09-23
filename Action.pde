public class Action<T> {
  
  private OnChangeListener listener;
  private T valOld, valNew;
  private String label;
  
  public Action(T vold, T vnew, String lb, OnChangeListener l) {
    valOld = vold;
    valNew = vnew;
    listener = l;
    hPos = 0;
    label = lb;
    label(label);
  }
  
  public void back(boolean b) {
    T temp = valOld;
    if (valOld.getClass() == Point.class) {
      temp = (T)(new Point(((Point)valOld).x, ((Point)valOld).y));
      valOld = (T)(new Point(((Point)valNew).x, ((Point)valNew).y));
    } else {
      valOld = valNew;
    }
    valNew = temp;
    listener.onChange(temp); //<>//
    listener.onRender(false);
    label((b?"Undo":"Redo")+": ["+label+"]");
  }

}