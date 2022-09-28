import React from "react"
import Groups from "../../components/groups"
import { shallow } from "enzyme"

describe("Groups component", () => {
  it("should render one groups", () => {
    const mockGroups = [
      {
        id: "9d4cd354b558aa59a842bc2e74cfd18a0f0ade1ba5277bfdfcacaa50916a8072",
        name: "CCADMIN_CLOUD_ADMINS",
      },
    ]
    const mockGroupMembers = {
      "9d4cd354b558aa59a842bc2e74cfd18a0f0ade1ba5277bfdfcacaa50916a8072": {
        data: { name: "C123", id: "123456789", fullname: "Max Musterman" },
      },
    }
    const wrapper = shallow(
      <Groups groups={mockGroups} groupMembers={mockGroupMembers} />
    )
    // console.log(wrapper.debug())
    expect(wrapper.find("ul.tree").exists()).toBe(true)
    expect(wrapper.find("li").length).toBe(1)
    expect(wrapper.find("li").text().includes("CCADMIN_CLOUD_ADMINS")).toBe(
      true
    )
  })
})
