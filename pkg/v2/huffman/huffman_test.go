package huffman_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/theprimeagen/vim-with-me/pkg/v2/ascii_buffer"
	byteutils "github.com/theprimeagen/vim-with-me/pkg/v2/byte_utils"
	"github.com/theprimeagen/vim-with-me/pkg/v2/huffman"
)

func TestHuffman(t *testing.T) {
	freq := ascii_buffer.NewFreqency()
	freq.Freq(byteutils.New8BitIterator([]byte{
		'A', 'A', 'A',
		'B', 'B',
		'C', 'D',
	}))

	data := huffman.CalculateHuffman(freq)
	require.Equal(t, data, []byte{
		0, 0, 0, 3, 0, 6,
		0, 'A', 0, 0, 0, 0, // 0
		0, 0, 0, 9, 0, 12,
		0, 'B', 0, 0, 0, 0, // 10
		0, 0, 0, 15, 0, 18,
		0, 'D', 0, 0, 0, 0, // 110
		0, 'C', 0, 0, 0, 0, // 111
	})
}