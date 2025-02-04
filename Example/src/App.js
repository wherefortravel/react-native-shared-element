// @flow
import * as React from "react";
import { StatusBar } from "react-native";
import { Router, ListItem } from "./components";
import { MainScreen } from "./screens";
import { ReactNavigationScreen } from "./screens/ReactNavigationScreen";

StatusBar.setTranslucent(true);
StatusBar.setBackgroundColor("transparent");

export class App extends React.Component<{}> {
  render() {
    return (
      <Router
        initialNode={
          <MainScreen
            footer={
              <ListItem
                label="React Navigation"
                description="React Navigation Demo"
                onPress={() => Router.push(<ReactNavigationScreen />)}
              />
            }
          />
        }
      />
    );
  }
}
