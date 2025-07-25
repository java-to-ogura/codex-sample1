// ファイル名：SimpleTest.java
package com.example.codexsample1;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class SimpleTest {
    @Test
    void testAdd() {
        assertEquals(2, 1 + 1);
    }
}
