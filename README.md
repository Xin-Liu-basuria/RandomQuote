# RandomQuote

### WHAT IS THIS

RandomQuote is a plugin for bitbar which can display sentence randomly from the list you added.

if you don't know what is bitbar,please click [here](https://github.com/matryer/bitbar)

### Example 

![default](https://user-images.githubusercontent.com/68738988/101983306-36bc7680-3cb5-11eb-9baa-8531007f2ba6.png)

![⌥ is pressed](https://user-images.githubusercontent.com/68738988/101983326-5e134380-3cb5-11eb-9c2b-240618f90402.png)

![a new random one](https://user-images.githubusercontent.com/68738988/101983352-8ef37880-3cb5-11eb-8b42-d77b969da81f.png)

### Features 

* Basic:display random quote from your list 
* Pin some sentence 
* Allow to display a parallel quote.Pressing ⌥ to see the alternative one.(this is usefull for bilingual quote)
* Send you notification at specific time 
* Be able to adjust the config easily and personize the best display effect

### Installation

1. ```shell
   git clone https://github.com/Xin-Liu-basuria/RandomQuote
   ```

2.  Open RandomQuote.xcodeproj (suppose that you have installed Xcode)

3. Set up your config file and resources file. See the format at Config behind for more info

4. please replace the path of config and resource.txt to yours ![here](https://user-images.githubusercontent.com/68738988/101983532-96ffe800-3cb6-11eb-9c66-03e266f0fdef.png)

5. 

   ```shell
   cd RandomQuote
   xcrun -sdk macosx swiftc  main.swift -o RandomQuote.1h.cswift
   ```

### Config 

#### config file

###### example

> maxCharDefault = 60
> maxCharAlternate = 35
> quoteColor = #C46243
> fontSize = 13
> fontKind = "Courier"
> pinQuote = [0,1]
> backspaceNumberForwardFrom = 100
> notificationHourList = [9,22]

those are the config you can set

PS: 

1.when the config value is an integer,please don't leave  backspace after the integer and just enter "return".

2.when the config value is an integer array,please don't leave any backspace in [ ].

 #### resources file

###### example

> #0.0.LOOK:THIS is default content
> #0.1.LOOK:THIS is alternate content when option key is pressed
> #0.2."I am the resource"
> #1.0.LOOK:I am the Pinned message.the one above is also.
> #1.2."from...."
> #2.0.I am a random one:1 <----here is not same
> #2.2.random
> #3.0.I am a random one:2 <----here is not same
> #3.2.random
> #4.0.I am a random one:2 <----here is not same
> #4.2.random

Every quote consists of "default content","alternative content" and "its resources"

PS: the label of those is 0,1,2 in turn.

Among those, ONLY "alternative content" is optional.

Every part should start with "#"+"serial"(from 0)+"."+"label"+"." 

## License

RandomQuote is available under the MIT license. See the LICENSE file for more info.