_: {
  services.glance.settings.pages = [
    {
      name = "Home";
      columns = [
        # Column 1: Small (unchanged)
        {
          size = "small";
          widgets = [
            {
              type = "calendar";
              firstDayOfWeek = "monday";
            }
            {
              type = "rss";
              limit = 10;
              collapseAfter = 3;
              cache = "12h";
              feeds = [
                {
                  url = "https://selfh.st/rss/";
                  title = "selfh.st";
                }
                { url = "https://samwho.dev/rss.xml"; }
              ];
            }
            {
              type = "twitch-channels";
              channels = [
                "theprimeagen"
                "christitustech"
              ];
            }
          ];
        }

        # Column 2: Full (unchanged)
        {
          size = "full";
          widgets = [
            {
              type = "group";
              widgets = [
                { type = "hacker-news"; }
                { type = "lobsters"; }
              ];
            }
            {
              type = "videos";
              channels = [
                "UCXuqSBlHAE6Xw-yeJA0Tunw" # Linus Tech Tips
                "UCsBjURrPoezykLs9EqgamOA" # Fireship
              ];
            }
          ];
        }

        # Column 3: Small (merged server stats + releases)
        {
          size = "small";
          widgets = [
            {
              type = "server-stats";
              servers = [
                {
                  type = "local";
                  name = "instance1";
                  mountpoints."/nix/store".hide = true;
                }
              ];
            }
            # {
            #   type = "weather";
            #   location = "Nantes, France";
            #   units = "metric";
            #   hourFormat = "12h";
            # }
            {
              type = "releases";
              cache = "1d";
              repositories = [
                "torvalds/linux"
                "glanceapp/glance"
              ];
            }
          ];
        }
      ];
    }
  ];
}
