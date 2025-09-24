package com.elgris.usersapi.models;

import javax.persistence.*;

@Entity
@Table(name = "users")
public class User {

    @Id
    @Column
    private String username;
    
    @Column
    private String firstname;
    
    @Column
    private String lastname;
    
    @Column
    @Enumerated(EnumType.ORDINAL) // Esto permite usar números: 0=USER, 1=ADMIN
    private UserRole role;

    // Getters y setters (los mismos que tienes)...
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public String getLastname() {
        return lastname;
    }

    public void setLastname(String lastname) {
        this.lastname = lastname;
    }

    public UserRole getRole() {
        return role;
    }

    public void setRole(UserRole role) {
        this.role = role;
    }
}