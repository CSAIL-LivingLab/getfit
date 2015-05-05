### Background: ###
    From November, 2014 to May, 2015, the MIT big data Living Lab team partnered with the MIT Medical getfit@MIT fitness challenge team to develop a mobile activity logger.

    For end-users, the app was a convenient way to track exercises. In addition to these logging tools, it included charts and graphs for users to analyze fitness progress. This was important for iPhone users, since the 2014-2015 GetFit website used flash, which is incompatible with iOS.

    For the Living Lab, the GetFit app was an opportunity to explore technical issues and social implications of big data on campus; and to better understand how to leverage data on campus to improve quality of life.

    The app makes use of two technologies emerging from MIT: The DataHub platform, and the OpenSense library.

    The DataHub platform is a hosted database system and interface developed at MIT’s CSAIL. It provides a repository for user data, and allows users to own, edit, share, and delete it at will.

    The OpenSense library is a data-collection program written at DTU and the MIT BigData LivingLab. It provides user-adjustable tools for apps to collect phone sensor data.

    The iOS app is here (iOS 7 +):
    https://itunes.apple.com/us/app/mit-getfit/id963967451
    https://github.com/CSAIL-LivingLab/getfit 

    Auxilary files and tools are here:
    https://projects.csail.mit.edu/bigdata/getfit-html
    https://github.com/CSAIL-LivingLab/getfit-html
    They hosted on the CSAIL server:  /afs/csail.mit.edu/proj/bigdata/www/data/getfit-html

    You can see a short presentation here:
    http://www.slideshare.net/albertrcarter/about-the-getfit-iphone-app?

    And fine some more notes for end users here:
    http://livinglab.mit.edu/getfit-faq

### Launch Notes ###

    The initial launch was bumpy. Instead of releasing at the start of the GetFit challenge (February 2, 2015), the app launched on March 16, the same morning that the App Store went down.

    Even after launch, the app suffered from notable bugs: 

    1) Users were sometimes unable to log minutes to the getfit@mit website; 
    2) the user continued to force users to re-login;
    3) an encryption oversight initially prevented background data collection.

    Issues 2 and 3 were eventually resolved. However, it wasn't possible to resolve issue 1, as this was due to the getfit@mit website's lack of an API. (The app was token scraping.)

### Engagement ###

    There was low engagement of the app. By the end of the challenge, we had averaged 3 users opening the app every day, with roughly 10 users logging background data.

### Suggestions for next time ###

    # Any app that asks for data from end users shoud also have graphics for them to consume. #

        This actually provides them with some of the benefits of data collection
    
    # Content should be hosted (not local) whenever possible. # 

        This should be obvious, but it's easy to skip over when initially building. With datahub, especially, you'll probably end up wanting to make schema changes later on. This is much easier to do when data is hosted.

    # Don't build on web apps unless they have an API. #

        Building on two experimental systems (Opensense and DataHub) is hard enough. Don't make things harder on yourself.

    # Use other 3rd party services for annotated data #

        Services like fidbit or moves can be used for annotating data, much like users currently do for getfit. I suspect that MIT's fidbit/moves userbase is on par with getfit. Moving away from getfit (which doesn't have an API) to other 3rd party services would also solve many of the stability issues that we have.

         Then, the app can be used just for background data collection.

    # Test on physical phones before releasing. #
        The simulator is good, but lacks some features, notably, encryption and reception fluctuations. Both of these features ended up causing issues after the app was launched.



You can contact arcarter@mit.edu or albert.r.carter@gmail.com to ask questions. I'm friendly.