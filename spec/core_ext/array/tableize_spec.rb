describe Array do
  context '#tableize' do
    context "on an Array of Arrays" do
      it 'normal case' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["Value3", "Value4"]]
        expected = <<-EOF
 Col1   | Col2
--------|--------
 Val1   | Val2
 Value3 | Value4
EOF
        expect(test.tableize).to eq(expected)
      end

      it 'with color' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["\033[31mValue3\e[0m", "Value4"]]
        expected = <<-EOF
 Col1   | Col2
--------|--------
 Val1   | Val2
 \e[31mValue3\e[0m | Value4
EOF
        expect(test.tableize).to eq(expected)
      end

      it 'with unterminated color' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["\033[31mValue3", "Value4"]]
        expected = <<-EOF
 Col1   | Col2
--------|--------
 Val1   | Val2
 \e[31mValue3\e[0m | Value4
EOF
        expect(test.tableize).to eq(expected)
      end

      it 'with numeric column values right justified' do
        test = [["Col1", "Col2"], ["Val1", 200], ["Value3", 30]]
        expected = <<-EOF
 Col1   | Col2
--------|------
 Val1   |  200
 Value3 |   30
EOF
        expect(test.tableize).to eq(expected)
      end

      it 'with really long column value' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["Really Really Long Value3", "Value4"]]
        expected = <<-EOF
 Col1                      | Col2
---------------------------|--------
 Val1                      | Val2
 Really Really Long Value3 | Value4
EOF
        expect(test.tableize).to eq(expected)
      end

      it 'with really long column value and color' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["\033[31mReally Really Long Value3\e[0m", "Value4"]]
        expected = <<-EOF
 Col1                      | Col2
---------------------------|--------
 Val1                      | Val2
 \e[31mReally Really Long Value3\e[0m | Value4
EOF
        expect(test.tableize).to eq(expected)
      end

      it 'with really long column value and :max_width option' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["Really Really Long Value3", "Value4"]]
        expected = <<-EOF
 Col1       | Col2
------------|--------
 Val1       | Val2
 Really Rea | Value4
EOF
        expect(test.tableize(:max_width => 10)).to eq(expected)
      end

      it 'with really long column value and color and :max_width option' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["\033[31mReally Really Long Value3\e[0m", "Value4"]]
        expected = <<-EOF
 Col1       | Col2
------------|--------
 Val1       | Val2
 \e[31mReally Rea\e[0m | Value4
EOF
        expect(test.tableize(:max_width => 10)).to eq(expected)
      end

      it 'with really long column value and color and :max_width option that chops off the color' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["Really Really Long \033[31mValue3\e[0m", "Value4"]]
        expected = <<-EOF
 Col1       | Col2
------------|--------
 Val1       | Val2
 Really Rea | Value4
EOF
        expect(test.tableize(:max_width => 10)).to eq(expected)
      end

      it 'with really long column value and color and :max_width option within an escape sequence' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["\033[31mReally Really Long Value3\e[0m", "Value4"]]
        expected = <<-EOF
 Co | Co
----|----
 Va | Va
 \e[31mRe\e[0m | Va
EOF
        expect(test.tableize(:max_width => 2)).to eq(expected)
      end

      it 'with oversized :max_width option' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["Really Really Long Value3", "Value4"]]
        expected = <<-EOF
 Col1                      | Col2
---------------------------|--------
 Val1                      | Val2
 Really Really Long Value3 | Value4
EOF
        expect(test.tableize(:max_width => 100)).to eq(expected)
      end

      it 'with color and oversized :max_width option' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["\033[31mReally Really Long Value3\e[0m", "Value4"]]
        expected = <<-EOF
 Col1                      | Col2
---------------------------|--------
 Val1                      | Val2
 \e[31mReally Really Long Value3\e[0m | Value4
EOF
        expect(test.tableize(:max_width => 100)).to eq(expected)
      end


      it 'with :header => false option' do
        test = [["Col1", "Col2"], ["Val1", "Val2"], ["Value3", "Value4"]]
        expected = <<-EOF
 Col1   | Col2
 Val1   | Val2
 Value3 | Value4
EOF
        expect(test.tableize(:header => false)).to eq(expected)
      end
    end

    context "on an Array of Hashes" do
      before do
        @str_case = [{"Col3" => "Val3", "Col2" => "Val2", "Col1" => "Val1"}, {"Col3" => "Value6", "Col2" => "Value5", "Col1" => "Value4"}]
        @sym_case = [{:Col3  => "Val3", :Col2  => "Val2", :Col1  => "Val1"}, {:Col3  => "Value6", :Col2  => "Value5", :Col1  => "Value4"}]
      end

      it "normal case" do
          expected = <<-EOF
 Col1   | Col2   | Col3
--------|--------|--------
 Val1   | Val2   | Val3
 Value4 | Value5 | Value6
EOF

        expect(@str_case.tableize).to eq(expected)
        expect(@sym_case.tableize).to eq(expected)
      end

      context "with :columns option" do
        before do
          @expected = <<-EOF
 Col3   | Col1   | Col2
--------|--------|--------
 Val3   | Val1   | Val2
 Value6 | Value4 | Value5
EOF
        end

        it "normal case" do
          expect(@str_case.tableize(:columns => ["Col3", "Col1", "Col2"])).to eq(@expected)
          expect(@sym_case.tableize(:columns => [:Col3,  :Col1,  :Col2 ])).to eq(@expected)
        end

        it "with only some values" do
          expected = <<-EOF
 Col3   | Col1
--------|--------
 Val3   | Val1
 Value6 | Value4
EOF

          expect(@str_case.tableize(:columns => ["Col3", "Col1"])).to eq(expected)
          expect(@sym_case.tableize(:columns => [:Col3,  :Col1 ])).to eq(expected)
        end

        it "and :leading_columns option" do
          expect(@str_case.tableize(:columns => ["Col3", "Col1", "Col2"], :leading_columns => ["Col1"])).to eq(@expected)
          expect(@sym_case.tableize(:columns => [:Col3,  :Col1,  :Col2 ], :leading_columns => [:Col1 ])).to eq(@expected)
        end

        it "and :trailing_columns option" do
          expect(@str_case.tableize(:columns => ["Col3", "Col1", "Col2"], :trailing_columns => ["Col1"])).to eq(@expected)
          expect(@sym_case.tableize(:columns => [:Col3,  :Col1,  :Col2 ], :trailing_columns => [:Col1 ])).to eq(@expected)
        end
      end

      it "with :leading_columns option" do
        expected = <<-EOF
 Col3   | Col2   | Col1
--------|--------|--------
 Val3   | Val2   | Val1
 Value6 | Value5 | Value4
EOF

        expect(@str_case.tableize(:leading_columns => ["Col3", "Col2"])).to eq(expected)
        expect(@sym_case.tableize(:leading_columns => [:Col3,  :Col2 ])).to eq(expected)
      end

      it "with :trailing_columns option" do
        expected = <<-EOF
 Col1   | Col3   | Col2
--------|--------|--------
 Val1   | Val3   | Val2
 Value4 | Value6 | Value5
EOF

        expect(@str_case.tableize(:trailing_columns => ["Col3", "Col2"])).to eq(expected)
        expect(@sym_case.tableize(:trailing_columns => [:Col3,  :Col2 ])).to eq(expected)
      end

      it "with both :leading_columns and :trailing_columns options" do
        expected = <<-EOF
 Col3   | Col1   | Col2
--------|--------|--------
 Val3   | Val1   | Val2
 Value6 | Value4 | Value5
EOF

        expect(@str_case.tableize(:leading_columns => ["Col3"], :trailing_columns => ["Col2"])).to eq(expected)
        expect(@sym_case.tableize(:leading_columns => [:Col3 ], :trailing_columns => [:Col2 ])).to eq(expected)
      end
    end

    it 'with an invalid receiver' do
      expect { [1, 2, 3].tableize }.to raise_error(RuntimeError)
    end
  end
end
