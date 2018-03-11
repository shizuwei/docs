# ThreadLocal代码分析

代码涉及的类：

`class ThreadLocal<T>`

- 基本用法

  ThreadLocal的神奇之处在于，定义一个变量可以内被附加到多个线程上。而且总是操作当前线程对应的那个变量。

  对一个单独的线程，一个ThreadLocal只能set一个对象。如果要多个，可以定义多个。

  ```java
  private static ThreadLocal<User> curAuthInfo = new ThreadLocal<User>(); 
  // 同一个类型，new一次就够了，可以被多个线程使用，总是操作当前线程ThreadLocal
  curAuthInfo.set(user);//把user添加到当前线程的ThreadLocalMap中(没有则创建)，以curAuthInfo.threadLocalHashCode作为key,不同的ThreadLocal对象，创建时key值不一样。这也意味着线程中可以有多个不同的ThreadLocal
  User user = curAuthInfo.get();//返回当前线程的ThreadLocalMap中以curAuthInfo.threadLocalHashCode作为key的对象。
  curAuthInfo.remove();//删除当前线程的ThreadLocalMap中以curAuthInfo.threadLocalHashCode作为key的对象
  ```

  ​

- 关键成员变量

` private final int threadLocalHashCode = nextHashCode();`每次创建`ThreadLocal`

的时候，都会给对象分配一个不同的`threadLocalHashCode `.

- 关键方法

  ```java
   public T get() {
          Thread t = Thread.currentThread(); //当前的线程
          ThreadLocalMap map = getMap(t); // 每个线程Thread有一个ThreadLocalMap成员变量
          if (map != null) {
              ThreadLocalMap.Entry e = map.getEntry(this); //找到当前线程的ThreadLocalMap中，用ThreadLocal.threadLocalHashCode作为key的ThreadLocalMap.Entry对象
              if (e != null) {
                  @SuppressWarnings("unchecked")
                  T result = (T)e.value; //这个值是ThreadLocal.set添加进去的T类型对象
                  return result;
              }
          }
          return setInitialValue();
      }
  ```

  ```java
    public void set(T value) {
          Thread t = Thread.currentThread();
          ThreadLocalMap map = getMap(t);
          if (map != null)
              map.set(this, value); //ThreadLocal做为key
          else
              createMap(t, value); // map只有在使用的时候才会创建
      }
  ```

  ```java
   public void remove() {
           ThreadLocalMap m = getMap(Thread.currentThread());
           if (m != null)
               m.remove(this); //从Thread的map中ThreadLocal做为key按删除
       }

  ```

- Thread

  `Thread`中有` ThreadLocal.ThreadLocalMap threadLocals`成员，是一个专门设计的`ThreadLocalMap`类型对象。这个对象引用开始是空的，只在`ThreadLocal.set`的时候才会创建。

- ThreadLocalMap

  这个是关键数据结构，是定制的Map。定义在`ThreadLocal`中：`static class ThreadLocalMap`。

  下面看一下具体实现：

  K-V entry：

  ```java
   static class Entry extends WeakReference<ThreadLocal<?>> { //本身是一个指向ThreadLocal的WeakReference
              /** The value associated with this ThreadLocal. */
              Object value; //附加了一个引用，作为K对应的Value，这个vlaue值本身不在ThreadLocal里面，而是放到了map中，这个实现比较奇特，ThreadLocal对象本身的只是为了创建一个key.

              Entry(ThreadLocal<?> k, Object v) { //key-value
                  super(k);//弱引用指向ThreadLocal， 把ThreadLocal对象看作key
                  value = v;
              }
          }

          /**
           * Increment i modulo len.
           */
          private static int nextIndex(int i, int len) { //冲突探测，线性探测法
              return ((i + 1 < len) ? i + 1 : 0);
          }
  ```

  意味着，ThreadLocal如果没有其它强引用，可以被JVM回收。想想，我们只要不引用ThreadLocal对象，他就会自动删除，这个符合一般对象的回收逻辑。如果不适用弱引用，则在ThreadLocal对象没有显示引用的情况下，依然会被ThreadLocalMap保持，如果要删除还得去调用对应线程的ThreadLocalMap的删除方法，按目前的实现得等到那个线程自己运行删除代码。

  ​

  hash表存储在数组中`private Entry[] table;`

  ```java
   ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
              table = new Entry[INITIAL_CAPACITY]; //初始化大小16
              int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1); //hash值
              table[i] = new Entry(firstKey, firstValue); //数组中都是弱引用
              size = 1;
              setThreshold(INITIAL_CAPACITY); // 2/3*INITIAL_CAPACITY 门槛值
          }

   private void set(ThreadLocal<?> key, Object value) {

              // We don't use a fast path as with get() because it is at
              // least as common to use set() to create new entries as
              // it is to replace existing ones, in which case, a fast
              // path would fail more often than not.

              Entry[] tab = table;
              int len = tab.length;
              int i = key.threadLocalHashCode & (len-1);

              for (Entry e = tab[i]; // 第一个位置
                   e != null;// 位置上已经有stale entry
                   e = tab[i = nextIndex(i, len)]) {// 找下一个位置，挨个向后看，循环的找
                  ThreadLocal<?> k = e.get();

                  if (k == key) { // 找到了，key值完全一样的，只需要修改value值即可。
                      e.value = value;
                      return;
                  }

                  if (k == null) { // 被jvm collector删除。
                      replaceStaleEntry(key, value, i); // 替换为要插入的key,replaceStaleEntry稍后分析，先分析remove
                      return; // 注意这里直接退出了
                  }
                  
                  // 继续往下找
              }
  			
       		// slot是空的，放进去
              tab[i] = new Entry(key, value);
              int sz = ++size;
              if (!cleanSomeSlots(i, sz) && sz >= threshold)
                  rehash();
          }

          /**
           * Remove the entry for key.
           */
          private void remove(ThreadLocal<?> key) {
              Entry[] tab = table;
              int len = tab.length;
              int i = key.threadLocalHashCode & (len-1);
              for (Entry e = tab[i];
                   e != null;
                   e = tab[i = nextIndex(i, len)]) {
                  if (e.get() == key) { // 调用函数时，由于key的引用还在，所以jvm不会由于弱引用的关系而导致e.get == null
                      e.clear(); // 使得e.get()==null
                      expungeStaleEntry(i);//见下面，删除tab[i]
                      return;
                  }
              }
          }
  // staleSlot 清理，并调整rehash，这个函数很关键。
   private int expungeStaleEntry(int staleSlot) { //删除旧的entry（即： tab[staleSlot]!=null的）
              Entry[] tab = table;
              int len = tab.length;

              // expunge entry at staleSlot
              tab[staleSlot].value = null; //value也清除
              tab[staleSlot] = null; // entry也清除
              size--;

              // Rehash until we encounter null 为啥到null就完了?下面仔细分析下，见分析1
              Entry e;
              int i;
              for (i = nextIndex(staleSlot, len);
                   (e = tab[i]) != null;
                   i = nextIndex(i, len)) { //挨着往下找staleentry，直到null
                  ThreadLocal<?> k = e.get();
                  if (k == null) { //jvm collector清除了
                      e.value = null;
                      tab[i] = null; //直接干掉
                      size--;
                  } else { //找到了一个有效的stale entry
                      int h = k.threadLocalHashCode & (len - 1);
                      if (h != i) { //出现过碰撞的，尝试重新放置到h
                          tab[i] = null; // i不是最好的位置，干掉

                          // Unlike Knuth 6.4 Algorithm R, we must scan until
                          // null because multiple entries could have been stale.
                          while (tab[h] != null) //h位置有可能被占据了
                              h = nextIndex(h, len);
                          tab[h] = e; //放回去h，这个位置可能比以前好
                      }
                  }
              }
              return i; // i指向null
          }
  ```



```java
         
private void replaceStaleEntry(ThreadLocal<?> key, Object value,                        										int staleSlot) {
          Entry[] tab = table;
          int len = tab.length;
          Entry e;

          // Back up to check for prior stale entry in current run.
          // We clean out whole runs at a time to avoid continual
          // incremental rehashing due to garbage collector freeing
          // up refs in bunches (i.e., whenever the collector runs).
          int slotToExpunge = staleSlot;
          for (int i = prevIndex(staleSlot, len);
               (e = tab[i]) != null; //整段
               i = prevIndex(i, len))
              if (e.get() == null)
                  slotToExpunge = i; //向前找到第一个被jvm删除的

          // Find either the key or trailing null slot of run, whichever
          // occurs first
          for (int i = nextIndex(staleSlot, len);
               (e = tab[i]) != null;
               i = nextIndex(i, len)) {
              ThreadLocal<?> k = e.get();

              // If we find key, then we need to swap it
              // with the stale entry to maintain hash table order.
              // The newly stale slot, or any other stale slot
              // encountered above it, can then be sent to expungeStaleEntry
              // to remove or rehash all of the other entries in run.
              if (k == key) {
                  e.value = value;

                  tab[i] = tab[staleSlot]; //后面已经有这个key了，把它换到前面
                  tab[staleSlot] = e;

                  // Start expunge at preceding stale entry if it exists
                  if (slotToExpunge == staleSlot) //现在staleSlot已经被放入了e,i才是需要清理的
                      slotToExpunge = i;
                  // 但如果staleSlot不是第一个需要清理的，还是从第一个开始清理
                  cleanSomeSlots(expungeStaleEntry(slotToExpunge), len);//清除slotToExpunge，并扫描其他的段中的jvm删除的entry，清除之。不是全面扫描，只是按log2(len)次扫描，可能不全哦~！
                  return;
              }

              // If we didn't find stale entry on backward scan, the
              // first stale entry seen while scanning for key is the
              // first still present in the run.
              if (k == null && slotToExpunge == staleSlot)
                  slotToExpunge = i; //staleSlot的位置会被替换，所以i才是要清除的。 这个判断只可能进去一次，所以slotToExpunge是第一个。至于为什么继续循环，是为了找k == key的元素
          }

          // If key not found, put new entry in stale slot
          // 找不到现成的，就创建一个，总之，staleSlot都不会被清空。
          tab[staleSlot].value = null;
          tab[staleSlot] = new Entry(key, value);

          // If there are any other stale entries in run, expunge them
          if (slotToExpunge != staleSlot)
              cleanSomeSlots(expungeStaleEntry(slotToExpunge), len);
      }
```

  - 分析1

  从构造map,到进行n次set之后，table如下：

  eeeennneeeneeeene 

  e代表entry，n代表null，反证法可以知道每个n后面的第一个e一定是没有冲突的，即tab[i].threadLocalHashCode & (len - 1) == i 我们把连续的e看作一段(run)，从左往右，第一个为段首。那么段首e后面的e只能和它前面的的同段的e冲突过，*所以调整的话只用调整本段(run)即可*，即调整到null出现。分析下可以发现按照remove的方式调整后，序列依旧满足这个性质，所以可以反复操作。

- 分析2

  由于key是若引用，如果外部的threadlocal的引用被清理掉，map里面entry的key会变为null, value却没有清除，如果thread依旧存在，可能导致value依旧被引用。所以要保留threadlocal的强引用，不用时remove一下(会删除value引用)。

  ```java
  new ThreadLocal<User>().set(user); //这样处理，可能会出问题
  ```

  ​

  此问题，参考http://blog.xiaohansong.com/2016/08/06/ThreadLocal-memory-leak/

  https://wiki.apache.org/tomcat/MemoryLeakProtection

  ​

  ​


