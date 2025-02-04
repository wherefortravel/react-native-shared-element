import * as React from "react";
import { View, findNodeHandle, ViewStyle } from "react-native";
import { SharedElementNode } from "./types";

export type SharedElementProps = ViewStyle & {
  children: React.ReactNode;
  onNode: (node: SharedElementNode | null) => void;
};

export function nodeFromRef(
  ref: any,
  isParent?: boolean,
  parentInstance?: any
): SharedElementNode | null {
  const nodeHandle = ref ? findNodeHandle(ref) : undefined;
  return nodeHandle
    ? {
        ref,
        nodeHandle,
        isParent: isParent || false,
        parentInstance
      }
    : null;
}

export class SharedElement extends React.Component<SharedElementProps> {
  private _node: SharedElementNode | null = null;

  render() {
    const {
      onNode, //eslint-disable-line @typescript-eslint/no-unused-vars
      ...otherProps
    } = this.props;
    return <View ref={this.onSetRef} collapsable={false} {...otherProps} />;
  }

  private onSetRef = (ref: any) => {
    this._node = nodeFromRef(ref, true, this);
    if (this.props.onNode) {
      this.props.onNode(this._node);
    }
  };

  componentDidUpdate(prevProps: SharedElementProps) {
    if (!prevProps.onNode && this.props.onNode && this._node) {
      this.props.onNode(this._node);
    }
  }
}
