package com.sample.users.model;

public class User {

    private long id;

    private String Name;

    public User() {
    }

    public long getId() {
        return id;
    }

    public String getName() {
        return Name;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", Name='" + Name + '\'' +
                '}';
    }
}
